#
# File::      HAMLProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# processes .haml source files to generate the associated HTML
#

module SiteFuel
  module Processor

    require 'sitefuel/extensions/Silently'

    # since the haml gem gives exec() warnings, we temporarily lower the verbosity
    # (last tested with 2.2.14, this might not be needed with a future version)
    silently { require 'haml' }

    require 'sitefuel/processors/AbstractStringBasedProcessor'
    require 'sitefuel/processors/HTMLProcessor'

    class HAMLProcessor < AbstractStringBasedProcessor

      def self.file_patterns
        ['.haml']
      end

      def self.default_filterset
        :generate
      end

      def self.filterset_generate
        [:generate, :minify]
      end

      # generate the raw .html file from a .haml file
      def filter_generate
        # to silence instance variable not initialized warnings from haml
        silently {
          engine = Haml::Engine.new(document)
          @document = engine.render
        }
      end

      # run the HTMLProcessor's whitespace filter
      def filter_minify
        @document = HTMLProcessor.filter_string(:whitespace, document)
      end

    end
  end
end