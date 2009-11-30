#
# File::      SiteFuelRuntime.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Defines the primary interface class used by sitefuel to do actual work.
# Keeping this as a class let's us abstract away the command line interface
# while automatically having a direct API for programatically accessing
# sitefuel.
#


module SiteFuel

  require 'optparse'
  
  require 'rubygems'
  require 'ruby-debug'
  require 'term/ansicolor'

  include Term::ANSIColor

  require 'SiteFuelLogger'

  require 'environment'
  require 'extensions/StringFormatting'
  require 'extensions/FileComparison'

  class SiteFuelRuntime

    include SiteFuel::Logging

    # what action is the runtime supposed to preform
    attr_accessor :action

    # what is the source *from* which we are deploying
    attr_accessor :deploy_from

    # what is the source *to* which we are deploying
    attr_accessor :deploy_to

    attr_accessor :deploymentconfiguration

    def initialize
      @processors = SiteFuelRuntime.find_processors
      self.logger = SiteFuelLogger.instance
    end

    # gives true if the given file (typially a processor) has already been
    # loaded (by looking into $")
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
      dir = File.dirname(__FILE__)+File::SEPARATOR

      # build up the search pattern by taking this file's direction and shoving
      # on the search patt
      patt = File.join(dir, 'processors/*Processor.rb')

      # find all file matching pattern
      files = Dir[patt]
      
      # rip off the path prefix so 'sitefuel/lib/foo.rb' becomes 'foo.rb'
      files = files.map do |filename|
        filename.gsub(Regexp.new("^"+Regexp.escape(dir)), '')
      end

      # get rid of anything we've loaded
      files = files.delete_if { |file| processor_loaded?(file) }

      # load whatever files we're left with
      files.each { |f| require f }
    end

    # returns a list of processors found by looking for all children of
    # SiteFuel::Processor::AbstractProcessor
    #
    # for a processor to be automatically included it has to:
    # * be loaded (TODO: all processors under processors/ are automatically loaded)
    # * be a child class of AbstractProcessor
    # * the class name must end with Processor
    #
    def self.find_processors
      # TODO: really profile this sucker; it seems quite scary to iterate over
      # all of the classes
      procs = []
      ObjectSpace.each_object(Class) do |cls|
        if [Processor::AbstractProcessor, Processor::AbstractStringBasedProcessor].include?(cls.superclass) and
           cls.to_s =~ /^.*Processor$/
        then
          procs << cls
        end
      end

      procs
    end

    # lists the actions which are possible with this runtime.
    def actions
      [ :deploy, :process ]
    end

    # gives the array of processors available to this runtime
    attr_reader :processors

    def add_processor(proc)
      @processors << proc
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
      rescue Processor::MultipleApplicableProcessors => excep
        # log the exception
        warn excep
        excep.chosen_processor
      end
    end

    # create a deployment
    def deploy
      return nil if @deploy_from == nil

      puts bold('Processing:')

      # find all files under deploy_from
      files = find_all_files @deploy_from

      @resource_processors = {}
      files.each do |filename|
        processor = choose_processor!(filename)
        if processor == nil
          @resource_processors[filename] = nil
        else
          @resource_processors[filename] = processor.process_file(filename)
        end
      end


      # print all results
      files.each do |filename|
        processor = @resource_processors[filename]
        if processor == nil
          puts '%s %s' %['--'.ljust(8), filename.cabbrev(65)]
        else
          processor.generate
          puts '%s %s %4.2f' % [bold(processor.class.processor_name.ljust(8)), filename.cabbrev(65).ljust(65), processor.processed_size.prec_f/processor.original_size.prec_f]
        end
      end

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

    # gives an array listing
    def find_all_files(path)
      Dir[File.join(path, "**/*")]
    end

    def verbosity(level = 1)
      case level
      when 1

      end
    end

    def findfiles(path)
      Dir.foreach(path) { |fname|
        puts "gots #{fname}"
      }
    end
  end


  # load the various processors
  SiteFuelRuntime.load_processors
end