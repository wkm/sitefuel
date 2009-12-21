#
# File::      PNGProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Interfaces with the rbcrush library that's wrapped around pngcrush
#

module SiteFuel
  module Processor

    require 'sitefuel/processors/AbstractExternalProgramProcessor'
    require 'sitefuel/external/PNGCrush'

    include External

    # processor for handling Portable Network Graphics images
    # currently operates as a lightweight wrapper around 'pngcrush'
    class PNGProcessor < AbstractExternalProgramProcessor
      def self.file_patterns
        ['.png']
      end

      #
      # External Program Handling
      #

      # gives the name of the pngcrush binary
      def self.program_binary
        'pngcrush'
      end

      def self.program_version_option
        '-version'
      end

      # we've only tested 1.5.10; but we're not using pngcrush
      # in any special way
      def self.appropriate_program_versions
        "> 1.5.0"
      end


      #
      # FILTERS AND FILTERSETS
      #

      def self.default_filterset
        :max
      end

      def self.filterset_quick
        [:quick]
      end

      def self.filterset_max
        [:brute_chainsaw]
      end


      #
      # FILTERS
      #
      
      def filter_brute
        SiteFuel::External::PNGCrush.brute(resource_name, output_filename)
      end

      def filter_quick
        SiteFuel::External::PNGCrush.quick(resource_name, output_filename)
      end

      def filter_brute_chainsaw
        SiteFuel::External::PNGCrush.chainsaw(resource_name, output_filename)
      end
    end

  end
end