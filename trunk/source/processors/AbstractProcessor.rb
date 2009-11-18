#
# File::      AbstractProcessor.rb
# Author::    wkm
# Copyright:: 2009
#
# Defines an AbstractProcessor class that gives the interface implemented by
# specific processors.
#

module SiteFuel
  module Processor

    # raised when a method isn't implemented by a child class.
    class NotImplemented < StandardError; end

    # raised when attempting to run a filter that doesn't exist
    class UnknownFilter < StandardError
      attr_reader :processor, :name

      def initialize(processor, name)
        @processor = processor
        @name = name
      end
    end

    # defines the base functions every processor must implement to
    # interface with the rest of the sitefuel interface
    #
    # note that a processor is declared to sitefuel by creating a class
    # which inherits AbstractProcessor. sitefuel looks at
    class AbstractProcessor

      # gives the display name for the processor
      def processor_name
        self.class.to_s.sub(/.*::(.*)Processor/, '\1')
      end

      # gives the file patterns that trigger the processor by default; this
      # behavior can be over-ridden by configuration files.
      def file_patterns
        []
      end

      # lists all the filters implemented by a processor
      def filters
        names = self.methods.delete_if { |method| not method =~ /^filter_.*$/ }
        names.map { |filter_name| filter_name.sub(/^filter_(.*)$/, '\1').to_sym }
      end

      # runs a particular filter
      def run_filter(name)
        if respond_to?("filter_" + name.to_s)
          self.send("filter_"+name.to_s)
        else
          UnknownFilter(self, name)
        end
      end

      # gives the default filterset used
      def default_filterset
        :whitespace
      end

      # comglomerates all the defaults,
      def defaults
        {
          :default_filterset => default_filterset,
          :filtersets => filtersets
        }
      end

      # gives the canonical name of the resource
      def resource_name
        raise NotImplemented
      end

      # gives the original size of a resource before being processed
      def original_size
        raise NotImplemented
        return 0
      end

      # gives the size of the resouce now that it's been processed
      def processed_size
        raise NotImplemented
        return 0
      end

      # gives the processed file content
      def generate
        raise NotImplemented
      end
      
    end
  end
end