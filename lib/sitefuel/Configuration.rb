#
# File::      configuration.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Load and process SiteFuel YAML configuration files
#

module SiteFuel
  require 'sitefuel/SiteFuelLogger'
  require 'yaml'

  # exception which represents that a configuration could not be found
  class Configuration

    include SiteFuel::Logging

    # given a directory path will attempt to location a configuration file
    # and load it, returning a SiteFuel::Configuration class
    def self.load(path, filename = 'deployment.yml')
      files = Dir["**/"+filename]

      if files.length < 0
        warn('No deployment configuration file found. Using defaults.')
        return
      end

      config_file = files.


      yamlconfig = YAML::load_file(configfile)
      
      Configuration.new(yamlconfig)
    end

    # builds a sitefuel configuration from a parsed YAML file
    def initialize(yamlconfig)
    end
  end
end