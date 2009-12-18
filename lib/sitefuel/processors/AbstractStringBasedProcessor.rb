#
# File::      AbstractStringBasedProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL
#
# Defines an abstract processor that runs by loading an entire file into
# memory as a string. Since most files we're looking at are very small
# anyway (seeing as they're intended to be served millions of times) this
# is usually fine.
#

module SiteFuel
  module Processor

    require 'sitefuel/processors/AbstractProcessor'

    class AbstractStringBasedProcessor < AbstractProcessor
      
      def self.processor_type
        'String'
      end

      # lightweight wrapper for opening a resource and generating the file
      def self.process_file(filename, config = {})
        proc = self.new()
        proc.configure(config)
        proc.open_file(filename)
        proc.generate
      end

      # opens a resource in-memory and returns the generated string
      def self.process_string(string, config = {})
        proc = self.new()
        proc.configure(config)
        proc.open_string(string)
        proc.generate_string
      end

      # mostly intended for debugging; applies a single filter directly
      # to a string
      #
      # filter can either be a single filter or an array of filters
      def self.filter_string(filter, string)
        proc = self.new()
        proc.configure(:filters => filter)
        proc.open_string(string)
        proc.generate_string
      end

      # opens a resource from a file
      def open_file(filename)
        self.document = File.read(filename)
        self.original_size = File.size(filename)
        self.resource_name = filename

        return self
      end

      # opens a resource directly from a string
      def open_string(string)
        self.document = string
        self.original_size = string.length
        self.resource_name = '<<in-memory string>>'
      end

      # generates the actual string
      def generate_string
        self.execute
        self.processed_size = @document.length

        document
      end

      # generates the string and shoves it into the deployment abstraction
      def generate
        generate_string
        return self
      end
      
      attr_reader :document
      
      protected
      attr_writer :document
    end
    
  end
end