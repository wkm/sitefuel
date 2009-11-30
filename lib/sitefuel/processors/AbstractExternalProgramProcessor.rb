#
# File::      AbstractExternalProgramProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  module Processor

    require 'sitefuel/processors/AbstractProcessor'

    
    # Defines an abstract processor that offloads the work onto an external program.
    # These are typically processors for handling binary files (eg. images)
    #
    # These processors spend a bunch of time ensuring the external program exists
    # and of the appropriate version; each filter then will typically setup more
    # parameters to pass to the program.
    class AbstractExternalProgramProcessor < AbstractProcessor

      # gives the name of the external program used to process files
      def self.program_name
        self.program_binary
      end

      # gives the location of the binary of the external program, this is
      # typically just the program name, eg. 'pngcrush' since it's found through
      # the +PATH+ environment variable
      def self.program_binary
        raise NotImplemented
      end

      # gives the suitable versions of the program to use
      def self.appropriate_program_versions
        "~> 0.0.0"
      end

      # gives the option to pass to #program_name to get the program's version
      def self.program_version_option
        "--version"
      end

      # given the version output of the program attempts to extract the
      # program's version
      def self.get_program_version(version_output)
        versions = version_output.scan(/\d+\.\d+(\.\d+)/)
        if versions.length == 0
          return nil
        else
          return versions[0]
        end
      end
      
    end

  end
end