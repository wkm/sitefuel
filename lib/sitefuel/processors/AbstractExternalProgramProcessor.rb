#
# File::      AbstractExternalProgramProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# TODO: this abstraction assumes only one filter will ever be run on a file,
# which is rather naive. Need to add support to process a file multiple times.
#


module SiteFuel
  module Processor

    require 'tempfile'
    require 'sitefuel/processors/AbstractProcessor'

    
    # Defines an abstract processor that offloads the work onto an external program.
    # These are typically processors for handling binary files (eg. images)
    #
    # These processors spend a bunch of time ensuring the external program exists
    # and of the appropriate version; each filter then will typically setup more
    # parameters to pass to the program.
    class AbstractExternalProgramProcessor < AbstractProcessor

      def initialize
        super
        @output_filename = nil
      end

      def self.processor_type
        'External'
      end

      def processor_symbol
        'E'
      end

      # processes a file using a given configuration
      def self.process_file(filename, config = {})
        info "#{self.class} opening for #{filename}"

        proc = self.new()
        proc.configure(config)
        proc.set_file(filename)
        proc.generate
      end

      # sets the file used by this processor
      def set_file(filename, resource_name=nil)
        case
          when (resource_name == nil and @resource_name == nil)
            @resource_name = filename

          when @resource_name != nil
            # just leave @resource_name be

          else
            @resource_name = resource_name
        end
        
        self.original_size = File.size(filename)

        return self
      end

      # gives the output filename for this processor; typically this will
      # be a temporary file.
      def output_filename
        if @output_filename == nil
          @output_filename = Tempfile.new(File.basename(resource_name)).path
        end

        @output_filename
      end

      # generates the new document using external programs
      def generate
        self.execute
        self.processed_size = File.size(output_filename)
        return self
      rescue SiteFuel::External::ProgramExitedWithFailure => exception
        error "When processing #{resource_name}:"
        error exception.to_s
      end

      def save(base_file_tree)
        final_filename = base_file_tree.get_file(resource_name)
        File.rename(output_filename, final_filename)
        info "Moved #{output_filename} to #{final_filename}"
      end
    end
  end
end