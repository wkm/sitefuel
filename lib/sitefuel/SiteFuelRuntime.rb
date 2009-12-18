#
# File::      SiteFuelRuntime.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL
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

  # we need the AbstractProcessor symbol when we go child-class hunting
  require 'sitefuel/processors/AbstractProcessor'

  # version of SiteFuel
  VERSION = [0, 0, 1].freeze

  # a human readable version
  VERSION_TEXT = VERSION.join('.').freeze
  

  class SiteFuelRuntime

    include SiteFuel::Logging

    # what action is the runtime supposed to preform
    attr_accessor :action

    # what is the source *from* which we are deploying
    attr_accessor :deploy_from

    # what is the source *to* which we are deploying
    attr_accessor :deploy_to

    # configuration loaded from a deployment.yml file
    attr_accessor :deploymentconfiguration

    # only lists file which have a known processor
    attr_accessor :only_list_recognized_files

    def initialize
      @processors = SiteFuelRuntime.find_processors
      self.logger = SiteFuelLogger.instance
      SiteFuelLogger.instance.log_style = :clean

      @only_list_recognized_files = false
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
      matchingprocs = processors.clone.delete_if {|proc| not proc.processes_file?(filename) }

      case
        when matchingprocs.length > 1
          chosen = matchingprocs.first
          raise Processor::MultipleApplicableProcessors.new(filename, matchingprocs, chosen)
        when matchingprocs.length == 1
          return matchingprocs.first
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


    # implements the stage command. Staging, by itself, will give statistics on
    # the deployment; how many bytes were saved by minification; etc.
    #
    # However, #stage when part of #deploy will go and create the requisite files
    # in a temporary directory
    def stage
      return nil if @deploy_from == nil

      puts '== %s '.format('Staging').ljust(80, '=')

      # find all files under deploy_from
      files = find_all_files @deploy_from

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
            puts '%s %s' %['--'.ljust(8), filename.cabbrev(65)]
          end
        else
          total_original_size += processor.original_size
          total_processed_size += processor.processed_size

          stats = @processor_statistics[processor.class.processor_name].clone
          stats[0] += 1
          stats[1] += processor.original_size
          stats[2] += processor.processed_size
          @processor_statistics[processor.class.processor_name] = stats

          puts '%s %s %4.3f' %
               [
                 cyan(processor.class.processor_name.ljust(8)),
                 filename.cabbrev(65).ljust(65),
                 processor.processed_size.prec_f/processor.original_size.prec_f
               ]
        end
      end

      puts '='*80
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
      puts '     %s | %s  |    %s    | %s' %
           ['processor', '# files', 'delta', 'ratio'].map{|v| bold(v)}
      puts '    -----------+----------+-------------+-------'
      
      @processor_statistics.keys.sort.each do |key|
        puts '     %s|%9d |%+12d | %4.3f' %
             [
               key.ljust(10),
               @processor_statistics[key][0],
               @processor_statistics[key][2] - @processor_statistics[key][1],
               @processor_statistics[key][2].prec_f / @processor_statistics[key][1].prec_f
             ]
      end
      puts '    -----------+----------+-------------+-------'
      puts ''
    end

    # create a deployment
    def deploy
      # first we have to stage the files
      stage

      files = find_all_files @deploy_from

      return if @deploy_to == nil
      puts
      puts bold('Deploying:')

      unless File.exists?(@deploy_to)
        Dir.mkdir(@deploy_to)
      end
      # write out content
      files.each do |filename|
        results = @resource_processors[filename]
        if results == nil
          putc 'I'
        else
          putc '.'
          results.save(@deploy_to)
        end
        STDOUT.flush
      end
      puts
    end

    # gives an array listing of all files on a given path
    #
    # This is a very lightweight wrapper around Dir.
    def find_all_files(path)
      Dir[File.join(path, "**/*")]
    end

    # changes the verbosity of the runtime by adjusting the log level
    def verbosity(level = 1)
      case level
      when 1

      end
    end
  end


  # load the various processors
  SiteFuelRuntime.load_processors
end