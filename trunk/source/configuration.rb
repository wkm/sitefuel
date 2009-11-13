#
# File::      configuration.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Load and process SiteFuel YAML configuration files
#

module SiteFuel
  require 'yaml'

  class Configuration

    # exception which represents that a configuration could not be found
    class NotFound < StandardError
    end

    # given a directory path will attempt to location a configuration file
    # and load it, returning a SiteFuel::Configuration class
    def self.load(path)
      unless File.exist?(path)
        throw NotFound, path
      end

      yamlconfig = YAML::load_file(configfile)
      
      Configuration.new(yamlconfig)
    endx`

    # builds a sitefuel configuration from a parsed YAML file
    def initialize(yamlconfig)
    end
  end
end