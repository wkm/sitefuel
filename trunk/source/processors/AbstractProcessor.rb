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

    # defines the base functions every processor must implement to
    # interface with the rest of the sitefuel interface
    #
    # note that a processor is declared to sitefuel by creating a class
    # which inherits AbstractProcessor. sitefuel looks at
    class AbstractProcessor

      # list the filtersets and the filters they map to
      # used to build up documentation
      #  HTMLProcessor.filtersets # => {:full=>[:whitespace,
      def filtersets
        {
          :full => [filters(:whitespace)],
          :whitespace => []
        }
      end

      # gives the filters a filterset will run
      def filters(filterset)
        raise NotImplemented
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
      def resourcename
        raise NotImplemented
      end

      def processorname
        self.class.to_s.sub(/.*::(.*)Processor/, '\1')
      end

      # gives the original size of a resource before being processed
      def originalsize
        raise NotImplemented
        return 0
      end

      # gives the size of the resouce now that it's been processed
      def processedsize
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