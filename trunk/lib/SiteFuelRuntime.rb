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

  require 'environment.rb'
  require 'processors/HTMLProcessor.rb'
  require 'processors/CSSProcessor.rb'
  require 'processors/SASSProcessor.rb'
  require 'mixins/StringFormatting.rb'

  class SiteFuelRuntime

    # what action is the runtime supposed to preform
    attr_accessor :action

    # what is the source *from* which we are deploying
    attr_accessor :deploy_from

    # what is the source *to* which we are deploying
    attr_accessor :deploy_to

    attr_accessor :deploymentconfiguration

    # lists the actions which are possible with this runtime.
    def actions
      [ :deploy, :process ]
    end

    # gives the array of processors available to this runtime
    def processors
      [ Processor::HTMLProcessor, Processor::CSSProcessor ]
    end

    # gives the processor to use for a given file
    def choose_processor(filename)
      matchingprocs = processors.delete_if {|proc| not proc.processes_file?(filename) }

      case
      when matchingprocs.length > 1
        chosen = matchingprocs.first
        raise Processor::MultipleApplicableProcessors(filename, matchingprocs, chosen)
      when matchingprocs.length == 1
        return matchingprocs.first
      else
        return nil
      end
    end

    # like #choose_processor but prints a message if there are clashing
    # processors
    def choose_processor!(filename)
      begin
        choose_processor(filename)
      rescue Processor::MultipleApplicableProcessors => execp
        puts excep
        excep.chosen_processor
      end
    end

    # create a deployment
    def deploy
      return nil if @deploy_from == nil

      # find all files under deploy_from
      files = find_all_files @deploy_from

      @processors = {}
      files.each do |filename|
        processor = choose_processor!(filename)
        if processor == nil
          @processors[filename] = nil
        else
          @processors[filename] = processor.process(filename)
        end
      end


      # print all results
      files.each do |filename|
        processor = @processors[filename]
        if processor == nil
          puts '--       '+filename
        else
          processor.generate
          puts '%s %s %4.2f' % [bold(processor.processor_name.ljust(8)), filename.abbrev(65).ljust(65), processor.processed_size.prec_f/processor.original_size.prec_f]
        end
      end
    end

    # gives an array listing
    def find_all_files(path)
      find_all_files_nested(path).flatten
    end

    # gives all files contained within a path
    # TODO this would probably be much more efficient if it wasn't recursive,
    # I suspect all of these File.join()s can be nicely streamlined to only
    # happen once. /wkm
    # TODO this whole function is stooooopid. It should just be Dir["**/*"]
    def find_all_files_nested(path)
      entries = Dir.entries(path)

      # get rid of self or parent references in a directory
      # also get rid of any hidden files TODO: this needs to be revisted with
      # some more robust black/white-listing mechanism
      entries = entries.delete_if { |i| [".", ".."].include?(i) or i =~ /^\./ }
      
      return entries.collect { |entry|
        # attach the start path to the entry
        fullentry = File.join(path, entry)

        if File.directory?(fullentry)
          find_all_files_nested(fullentry)
        else
          fullentry
        end
      }
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
end