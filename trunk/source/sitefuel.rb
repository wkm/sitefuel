#!/usr/bin/ruby
#
# File::      sitefuel.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# === Introduction
# sitefuel is a lightweight ruby framework for deploying websites directly from
# version control. sitefuel includes support for compressing HTML and CSS as
# well as optimizing PNG graphics. Support is planned for SASS; compressing
# JavaScript; automatically creating sprites; and supporting more image formats.
# (and more!)
#
#
# === Examples
# Process an already deployed site:
# <pre>sitefuel process /var/www/</pre>
#
# Deploy a site from SVN:
# <pre>sitefuel deploy svn+ssh://sitefuel.org/svn/tags/21 /var/www/</pre>
#
# Specify a non-default deployment file:
# <pre>sitefuel process /var/www/ -c customdeployment.yml</pre>
#

module SiteFuel

  # add this file's directory to the load path
  $:.unshift(File.dirname(__FILE__))

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