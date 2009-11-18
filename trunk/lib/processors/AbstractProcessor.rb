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
    # interface with the sitefuel architecture
    class AbstractProcessor

      #
      # PROCESSOR INFORMATION
      #

      # gives the display name for the processor
      def processor_name
        self.class.to_s.sub(/.*::(.*)Processor/, '\1')
      end

      # gives the file patterns that trigger the processor by default; this
      # behavior can be over-ridden by configuration files.
      #
      # * strings are assumed to be extensions and are tested for a literal match
      # * regexes are tested against the entire file name
      #
      def file_patterns
        []
      end

      # gives +true+ if filename matches one of #file_patterns.
      def processes_file?(filename)
        file_patterns.map { |patt|
          case patt
          when String
              regex = "^.*"+Regexp.escape(patt)+"$"
              return true if filename.downcase.match(regex) != nil
          when Regexp
              return true if filename.match(patt) != nil
          end
        }
        
        # if we got this far nothing matched
        return false
      end


      #
      # FILTER SET SUPPORT
      #

      # gives the default filterset used
      def default_filterset
        :whitespace
      end

      # evaluate a filterset
      def run_filterset(name)
        if respond_to?("filterset_" + name.to_s)
          self.send("filterset_" + name.to_s)
        else
          raise UnknownFilterset(self, name)
        end
      end



      #
      # FILTER SUPPORT
      #

      # lists all the filters implemented by a processor
      def filters
        names = self.methods.sort.delete_if { |method| not method =~ /^filter_.*$/ }
        names.map { |filter_name| filter_name.sub(/^filter_(.*)$/, '\1').to_sym }
      end

      # runs a particular filter
      def run_filter(name)
        if respond_to?("filter_" + name.to_s)
          self.send("filter_"+name.to_s)
        else
          raise UnknownFilter.new(self, name)
        end
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
      
    end
  end
end