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

  class SiteFuelRuntime

    # what action is the runtime supposed to preform
    attr_accessor :action

    # what is the source *from* which we are deploying
    attr_accessor :deploy_from

    # what is the source *to* which we are deploying
    attr_accessor :deploy_to

    #
    attr_accessor :deploymentconfiguration


    # parse the command line arguments and set the appropriate internal
    # values
    def process_command_line
      opts = OptionParser.new


      opts.banner = "SiteFuel #{$SiteFuelVersion.join('.')}\n\nA ruby framework for deploying sites from version control.\n\nUsage: sitefuel COMMAND ARGUMENTS [OPTIONS]"
      opts.separator ""
      opts.separator "Specific options:"
      
      opts.on('-v', '--version', 'Gives the version of sitefuel') {|| puts 'sitefuel ' + $SiteFuelVersion.join('.')}
      opts.on('--[no-]verbose', 'Cause sitefuel to be verbose, listing actions as they are preformed') {|| puts 'cause sitefuel to be verbose listing actions as they are preformed' }

      opts.separator ''
      opts.separator 'Common options:'
      opts.on('-oARG', '-o=ARG', '-o PLACE', '--output=ARG', '--output PLACE', String, 
              'Where to put a deployed site') do |out|
        puts "putting in #{out}"
      end

      opts.on('-h', '--help', '-?', '--about', 'Show this message') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'More information: http://sitefuel.org'
      opts.separator 'Getting started: http://sitefuel.org/getstarted'

      rest = opts.parse(*ARGV)
      puts "rest: #{rest.join(', ')}"
      
    end

    def actions
      [:deploy, :process]
    end

    def verbosity(level = 1)
      
    end

    def run
      process_command_line
      findfiles(Dir.getwd)
    end

    def findfiles(path)
      Dir.foreach(path) { |fname|
        puts "gots #{fname}"
      }
    end
  end
end

if $0 == __FILE__
  runtime = SiteFuel::SiteFuelRuntime.new
  runtime.run
end