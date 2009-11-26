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

    require 'SiteFuelLogger'

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

    # raised when multipe processors trigger off of a single file
    class MultipleApplicableProcessors < StandardError
      attr_reader :filename, :processors, :chosen_processor

      def initialize(filename, processors, chosen_processor)
        @filename = filename
        @resource_processors = processors
        @chosen_processor = chosen_processor
      end

      def to_s
        "MultipleApplicableProcessors: File '%s' triggered processors: %s. Using %s" %
        [@filename, @resource_processors.join(', '), @chosen_processor]
      end
    end

    # defines the base functions every processor must implement to
    # interface with the sitefuel architecture
    class AbstractProcessor

      include SiteFuel::Logging

      # setup an AbstractProcessor
      def initialize
        self.logger = SiteFuelLogger.instance
      end


      #
      # PROCESSOR INFORMATION
      #

      # gives the canonical name of the resource
      attr_reader :resource_name

      # gives the original size of a resource before being processed
      attr_reader :original_size

      # gives the size of the resouce now that it's been processed
      attr_reader :processed_size

      # gives the display name for the processor
      def self.processor_name
        self.to_s.sub(/.*\b(.*)Processor/, '\1')
      end

      # gives the file patterns that trigger the processor by default; this
      # behavior can be over-ridden by configuration files.
      #
      # * strings are assumed to be extensions and are tested for a literal match
      # * regexes are tested against the entire file name
      #
      def self.file_patterns
        []
      end

      # gives +true+ if filename matches one of #file_patterns.
      def self.file_pattern_match?(filename)
        file_patterns.map { |patt|
          case patt
          when String
              regex = Regexp.new("^.*"+Regexp.escape(patt)+"$", Regexp::IGNORECASE)
              return true if filename.match(regex) != nil
          when Regexp
              return true if filename.match(patt) != nil
          end
        }
        
        # if we got this far nothing matched
        return false
      end

      # uses #file_pattern_match? to decide if the file can be processed
      # eventually this may use other metrics (like mime types)
      def self.processes_file?(filename)
        file_pattern_match? filename
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
      def self.filters
        names = instance_methods.sort.delete_if { |method| not method =~ /^filter_.*$/ }
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

    protected
      # gives the raw document handle used by the processor
      attr_accessor :document

      # gives write-access to children classes
      attr_writer :original_size
      attr_writer :processed_size
      attr_writer :resource_name
      
    end
  end
end