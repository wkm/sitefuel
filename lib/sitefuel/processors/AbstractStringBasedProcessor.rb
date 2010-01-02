#
# File::      AbstractStringBasedProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
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

      def processor_symbol
        'S'
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
      def open_file(filename, resource_name = nil)
        info "#{self.class} opening #{filename}"

        self.document = File.read(filename)
        self.original_size = File.size(filename)

        case
          when (resource_name == nil and @resource_name == nil)
            @resource_name = filename

          when @resource_name != nil
            # just leave @resource_name be

          else
            @resource_name = resource_name            
        end

        debug "\t\tOpened with resource name: '#{@resource_name}'"

        return self
      end

      # opens a resource directly from a string
      def open_string(string)
        info "#{self.class} opening in embedded mode"

        self.document = string
        self.original_size = string.length
        self.resource_name = '<<embedded string>>'
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

      def save(file_tree)
        file_name = create_file(file_tree)
        File.open(file_name, 'w') do |file|
          file << @document
        end

        info "Wrote document into #{file_name}"
      end
      
      attr_reader :document
      
      protected
      attr_writer :document
    end
    
  end
end