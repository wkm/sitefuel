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

    def actions
      [ :deploy, :process ]
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

if $0 == __FILE__
  runtime = SiteFuel::SiteFuelRuntime.new
  runtime.run
end