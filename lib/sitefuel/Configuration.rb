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

    DEFAULT_CONFIGURATION_FILE = 'deployment.yml'

    # given a directory path will attempt to location a configuration file
    def self.find_configuration(path, filename = DEFAULT_CONFIGURATION_FILE)
      files = Dir["**/"+filename]

      if files.length < 0
        return nil
      elsif files.length > 1
        warn("Multiple  possible configuration files found: #{files.join(', ')}; using #{files.first}")
        return files.first
      else
        return files.first
      end
    end


    # given a directory path will attempt to find and load a
    # configuration file
    def self.load_configuration(runtime, path, filename = DEFAULT_CONFIGURATION_FILE)
      configuration_file = find_configuration(path, filename)

      if configuration_file == nil
        warn('No deployment configuration file found. Using defaults.')
        return Configuration.new(runtime, nil)
      else
        yaml = YAML::load_file(configuration_file)
        return Configuration.new(runtime, yaml)
      end
    end

    
    # builds a sitefuel configuration from a parsed YAML file
    def initialize(runtime, yaml_config)
      @processor_configurations = Hash.new([])
      @runtime = runtime

      load_yaml_config(yaml_config)
    end


    # loads a yaml configuration
    def load_yaml_config(yaml_config)
      
    end


    # gives an array of configuration options for the processor
    def processor_configuration(processor)
      @processor_configurations[processor]
    end
  end
end