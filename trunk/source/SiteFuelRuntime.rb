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
  require 'environment.rb'
  require 'processors/HTMLProcessor.rb'
  require 'processors/CSSProcessor.rb'
  require 'processors/SASSProcessor.rb'

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

    # create a deployment
    def deploy
      return nil if @deploy_from == nil

      # find all files under deploy_from
      files = find_all_files @deploy_from

      @processors = {}
      files.each do |filename|
        case filename
        when /.*\.html$/i:
            @processors[filename] = Processor::HTMLProcessor.process(filename)

        when /.*\.css$/i:
            @processors[filename] = Processor::CSSProcessor.process(filename)
        end
      end


      # print all results
      files.each do |filename|
        processor = @processors[filename]
        if processor == nil
          puts '--       '+filename
        else
          processor.generate
          puts '%s %s %4.2f' % [processor.processor_name.ljust(8), skeleton(filename, 65), processor.processed_size.prec_f/processor.original_size.prec_f]
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

    # TODO: move into String
    def skeleton(string, length)
      if string.length < length
        return string.ljust(length)
      else
        string[0..(length/2-2).floor] + "..." + string[(string.length - length/2-1) .. (string.length)]
      end
    end

    def verbosity(level = 1)
      case level
      when 1:

      end
    end

    def findfiles(path)
      Dir.foreach(path) { |fname|
        puts "gots #{fname}"
      }
    end
  end
end