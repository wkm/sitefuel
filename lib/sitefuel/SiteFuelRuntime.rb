#
# File::      SiteFuelRuntime.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Defines the primary interface class used by sitefuel to do actual work.
# Keeping this as a class let's us abstract away the command line interface
# while automatically having a direct API for programatically accessing
# sitefuel.
#


module SiteFuel

  require 'optparse'

  require 'term/ansicolor'

  include Term::ANSIColor

  require 'sitefuel/SiteFuelLogger'

  require 'sitefuel/extensions/StringFormatting'
  require 'sitefuel/extensions/FileComparison'
  require 'sitefuel/extensions/TerminalInfo'
  require 'sitefuel/extensions/ColumnPrinter'
  require 'sitefuel/extensions/FileTree'

  # we need the AbstractProcessor symbol when we go child-class hunting
  require 'sitefuel/processors/AbstractProcessor'

  require 'sitefuel/external/SVN'
  require 'sitefuel/external/GIT'

  # version of SiteFuel
  VERSION = [0, 1, '0a'].freeze

  # a human readable version
  VERSION_TEXT = VERSION.join('.').freeze


  class UnknownVersioningSystem < StandardError
    attr_reader :source
    def initialize(source)
      @source = source
    end

    def to_s
      "Couldn't derive versioning system from #{source}\n"+
      "Use --scm=(git|svn) option to force."
    end
  end
  

  class SiteFuelRuntime

    include SiteFuel::Logging

    # what action is the runtime supposed to preform
    attr_accessor :action

    # what is the source *from* which we are deploying
    attr_accessor :deploy_from

    # what is the staging directory
    attr_reader :staging_directory

    # what is the scm system
    attr_accessor :scm_system

    # what is the source *to* which we are deploying
    attr_accessor :deploy_to

    # configuration loaded from a deployment.yml file
    attr_accessor :deploymentconfiguration

    # only lists file which have a known processor
    attr_accessor :only_list_recognized_files

    # whether a deployment should be aborted due to errors
    attr_accessor :abort_on_errors

    # whether a deployment should be aborted due to warnings
    attr_accessor :abort_on_warnings


    def initialize
      @processors = SiteFuelRuntime.find_processors
      self.logger = SiteFuelLogger.instance
      SiteFuelLogger.instance.log_style = :clean

      @only_list_recognized_files = false

      @abort_on_errors = true
      @abort_on_warnings = false

      @scm_system = nil
    end


    # gives true if the given file (typically a processor) has already been
    # loaded (by looking into $"). Unfortunately #require is easily tricked,
    # so this function uses some heuristics to prevent processors from being
    # loaded twice (by basically comparing the "core" part of the filename)
    def self.processor_loaded?(file)
      $".map do |f|
        if File.equivalent?(file, f)
          return true
        end
      end
      
      return false
    end


    # finds all processors under processors/ and loads them. Any file matching
    # *Processor.rb will be loaded
    def self.load_processors
      dir = File.dirname(__FILE__).split(File::SEPARATOR)
      dir = File.join(*dir[0..-2]) + File::SEPARATOR

      # build up the search pattern by taking this file's directory and shoving
      # it onto the search pattern
      patt = File.join(dir, 'sitefuel/processors/*Processor.rb')

      # find all file matching that pattern
      files = Dir[patt]
      
      # rip off the path prefix eg. 'sitefuel/lib/b/foo.rb' becomes 'b/foo.rb'
      files = files.map do |filename|
        filename.gsub(Regexp.new("^"+Regexp.escape(dir)), '')
      end

      # get rid of anything we've already loaded
      files = files.delete_if { |file| processor_loaded?(file) }

      # load whatever files we're left with
      files.each { |f| require f }
    end

    
    # returns a list of processors found by looking for all children of
    # SiteFuel::Processor::AbstractProcessor
    #
    # for a processor to be automatically included it has to:
    # * be loaded (see #load_processors)
    # * be a child class of AbstractProcessor
    # * the class name must end with Processor
    #
    def self.find_processors
      Processor::AbstractProcessor.find_processors
    end


    # lists the actions which are possible with this runtime.
    def actions
      [ :deploy, :stage ]
    end


    # gives the array of processors available to this runtime
    attr_reader :processors


    # adds a processor or an array of processors to the runtime
    def add_processor(proc)
      case proc
        when Array
          proc.each { |p|
            @processors << p
          }
        else
          @processors << proc
      end
    end


    # gives the processor to use for a given file
    def choose_processor(filename)
      matching = processors.clone.delete_if {|proc| not proc.processes_file?(filename) }

      case
        when matching.length > 1
          chosen = matching.first
          raise Processor::MultipleApplicableProcessors.new(filename, matching, chosen)
        when matching.length == 1
          return matching.first
        else
          return nil
      end
    end


    # like #choose_processor but prints a message if there are clashing
    # processors and returns the first of the clashing processors.
    # (effectively alerting the user, but continuing to work)
    def choose_processor!(filename)
      begin
        choose_processor(filename)
      rescue Processor::MultipleApplicableProcessors => exception
        # log the exception
        warn exception
        exception.chosen_processor
      end
    end

    def section_divider(name)
      puts "== #{name} ".ljust(TerminalInfo.width, '=')
    end


    # decides what repository system to use (SVN or Git) based on the
    # pull source given (eg. ssh://... is typically git; svn+ssh://... is SVN,
    # etc.)
    def classify_repository_system(pull_source)

      # note that http:// and https:// repositories, in general could be
      # anything.
      case pull_source
        when /^git:\/\/.*$/i,
             /^ssh:\/\/.*$/i,
             /^rsync:\/\/.*$/i,
             /^.*\.git$/i
          :git

        when /^svn:\/\/.*$/i,
             /^svn\+ssh:\/\/.*$/i,
             /^file:\/\/.*$/i
          :svn

        when /^([-.a-zA-Z0-9\/])*$/i
          :filesystem

        else
          raise UnknownVersioningSystem.new(pull_source)
      end
    end                               

    def classify_repository_system!(pull_source)
      classify_repository_system(pull_source)
    rescue UnknownVersioningSystem => exception
      fatal(exception.to_s)
      exit(-1)
    end


    # pulls files out of a given repository or file system
    def pull
      if @scm_system == nil
        @scm_system = classify_repository_system!(@deploy_from)
        info "Using #{@scm_system} version control to access #{@deploy_from}"
      end

      # TODO this should be modularized; but in general there should be a
      # 'discoverable' class that automates creation of plugins

      case @scm_system.to_sym
        when :svn
          @staging_directory = External::SVN.export(@deploy_from)

        when :git
          @staging_directory = External::GIT.shallow_clone(@deploy_from)

        when :filesystem
          # kind of dangerous because it can override the source files; it's
          # assumed every processor will not override the original.
          @staging_directory = @deploy_from

        else
          fatal "Unknown SCM system: #{@scm_system}"
          exit(-1)
      end

      info "Pulled files for staging into #{@staging_directory}"

    rescue External::ProgramExitedWithFailure => exception
      fatal "Couldn't pull files from SCM:\n#{exception}"
    end


    # implements the stage command. Staging, by itself, will give statistics on
    # the deployment; how many bytes were saved by minification; etc.
    #
    # However, #stage when part of #deploy will go and create the requisite files
    # in a temporary directory
    def stage
      pull

      return nil if @staging_directory == nil

      section_divider('Staging')
      printer = ColumnPrinter.new([5, :span, 6])

      # find all files under deploy_from
      files = find_all_files @staging_directory

      total_original_size = 0
      total_processed_size = 0
      @resource_processors = {}
      @processor_statistics = Hash.new([0, 0, 0])
      files.each do |filename|
        processor = choose_processor!(filename)
        if processor == nil
          @resource_processors[filename] = nil
        else
          @resource_processors[filename] = processor.process_file(filename)
        end
        
        processor = @resource_processors[filename]
        if processor == nil
          if only_list_recognized_files == false
            printer.row('--', filename)
          end
        else
          total_original_size += processor.original_size
          total_processed_size += processor.processed_size

          stats = @processor_statistics[processor.class.processor_name].clone
          stats[0] += 1
          stats[1] += processor.original_size
          stats[2] += processor.processed_size
          @processor_statistics[processor.class.processor_name] = stats

          printer.row(
            cyan(processor.class.processor_name),
            filename,
            '%4.3f'%(processor.processed_size.prec_f/processor.original_size.prec_f)
          )
        end
      end

      printer.divider
      
      puts 'Size delta:         %+5d bytes; %4.3f' %
              [
                total_processed_size - total_original_size,
                total_processed_size.prec_f/total_original_size.prec_f
              ]

      staging_statistics
    end


    # outputs a little grid showing the number of files of each processor
    # and the total savings
    #
    # todo: this should be computed in the staging step
    def staging_statistics

      puts ''

      printer = ColumnPrinter.new([12, 8, :span, 6], [TerminalInfo.width, 50].min)
      printer.alignment([:left, :right, :right, :right])
      printer.mode(:divided)

      headers = %w{processor files delta ratio}.map{|v| bold(v)}
      printer.row(*headers)
      printer.divider
      
      @processor_statistics.keys.sort.each do |key|
        printer.row(
          key,
          @processor_statistics[key][0],
          '%+12d'%(@processor_statistics[key][2] - @processor_statistics[key][1]),
          '%4.3f'%(@processor_statistics[key][2].prec_f / @processor_statistics[key][1].prec_f)
        )
      end
      printer.divider
      puts ''
    end


    def check_messages
      error_count = SiteFuelLogger.instance.error_count
      if @abort_on_errors and error_count > 0
        fatal "Aborting due to errors. Use --force to deploy anyway."
        exit(-1)
      end

      warn_count = SiteFuelLogger.instance.error_count
      if @abort_on_warnings and warn_count > 0
        fatal "Aborting due to warnings. Use --ignore-warnings to deploy anyway."
        exit(-1)
      end
    end


    # create a deployment
    def deploy
      # first we have to stage the files
      stage

      check_messages

      return if @deploy_to == nil

      section_divider('Deploying')

      file_tree = FileTree.new(@deploy_to)
      
      # write out content
      @resource_processors.each_key do |filename|
        results = @resource_processors[filename]
        if results == nil
          putc '.'
        else
          putc results.processor_symbol
          results.save(file_tree)
        end
        STDOUT.flush
      end


      finish
    end

    def finish
      puts ''
      puts ''
      section_divider('Finishing')
    end


    # gives an array listing of all files on a given path
    #
    # This is a very lightweight wrapper around Dir.
    def find_all_files(path)
      if File.directory?(path)
        Dir[File.join(path, "**/*")]
      elsif File.file?(path)
        return path
      else
        return []
      end
    end

    
    # changes the verbosity of the runtime by adjusting the log level
    def verbosity(level = 1)
      case level
        when 0
          SiteFuelLogger.instance.level = Logger::FATAL

        when 1
          SiteFuelLogger.instance.level = Logger::ERROR

        when 2
          SiteFuelLogger.instance.level = Logger::WARN

        when 3
          SiteFuelLogger.instance.level = Logger::INFO

        when 4
          SiteFuelLogger.instance.level = Logger::DEBUG

        else
          warn "Unknown verbosity level: #{level}; ignoring."
      end
    end
  end


  # load the various processors
  SiteFuelRuntime.load_processors
end