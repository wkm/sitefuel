#
# File::      Configurable.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Implements a general abstraction for configuring a class instance
#

module SiteFuel
  module Processor
    module Configurable

      class UnknownConfigurationOption < StandardError
        attr_reader :class_name, :option_name
        def initialize(class_name, option_name)
          @class_name = class_name
          @option_name = option_name
        end

        def to_s
          "Class #{class_name} has no known option '#{option_name}'"
        end
      end



      # gives a list of all configurable options for this class
      def configuration_options
        names = methods.map do |name|
          if name =~ /^configure_(.*)$/
            $1.to_sym
          else
            nil
          end
        end

        names.compact
      end


      def pre_configuration
        # stub to be overriden by child classes
      end


      def post_configuration
        # stub to be overriden by child classes
      end


      # configures a particular instance given a hash; runs #pre_configuration
      # before running any particular config method and #post_configuration
      # afterwards
      def configure(config = {})
        pre_configuration

        unless config == nil or config == {}
          config.each_pair do |k, v|
            set_configuration(k, v)
          end
        end

        post_configuration
      end


      # ensures the given option name is configurable; otherwise
      # raises a UnknownConfigurationOption exception
      def ensure_configurable_option (name)
        if configuration_options.include?(name.to_sym)
          return true
        else
          raise UnknownConfigurationOption.new(self.class, name)
        end
      end


      # sets the configuration for a single option
      def set_configuration(key, value)
        ensure_configurable_option(key)
        method = "configure_" + key.to_s

        case value
          when Array
            send(method.to_sym, *value)

          else
            send(method.to_sym, value)
        end
      end
    end
  end
end