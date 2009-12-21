#
# File::      SASSProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# processes .sass stylesheets to generate the associated CSS
#

module SiteFuel
  module Processor
    require 'sitefuel/extensions/Silently'

    # since the haml gem gives exec() warnings, we temporarily lower the verbosity
    # (last tested with 2.2.14, this might not be needed with a future version)
    silently { require 'sass' }

    require 'sitefuel/processors/AbstractStringBasedProcessor'
    require 'sitefuel/processors/CSSProcessor'

    class SASSProcessor < AbstractStringBasedProcessor

      def self.file_patterns
        ['.sass']
      end
      
      def self.default_filterset
        :generate
      end

      def self.filterset_generate
        [:generate, :minify]
      end

      # generates the raw .css file from a .sass file
      #
      # TODO it's very important that generate be the first filter run
      def filter_generate
        engine = Sass::Engine.new(document)
        @document = engine.render
      end

      # runs the CSSProcessor's minify filter
      def filter_minify
        @document = CSSProcessor.filter_string(:minify, document)
      end

    end
  end
end