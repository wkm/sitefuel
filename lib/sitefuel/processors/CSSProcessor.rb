#
# File::      CSSProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Rather lightweight CSS processor; primarily intended to minify CSS, but has
# basic support for beautifcation as well
#

module SiteFuel
  module Processor

    require 'cssmin'

    require 'sitefuel/processors/AbstractStringBasedProcessor'

    class CSSProcessor < AbstractStringBasedProcessor

      # file patterns for CSS
      def self.file_patterns
        [".css"]
      end

      #
      # FILTER SETS
      #

      # gives the default filterset to run
      def self.default_filterset
        :minify
      end

      # gives the minify filter to run
      def self.filterset_minify
        [:minify]
      end

      # beautifies the source
      def self.filterset_beautify
        [:beautify]
      end



      #
      # FILTERS
      #

      # strips comments out of CSS using Regexp
      def filter_strip_comments

      end

      # lightweight minification by removing excess whitespace
      def filter_clean_whitespace

      end

      # lightweight beautifier that works through Regexp, adds whitespace above
      # line comments, puts each declaration on it's own line. etc.
      def filter_beautify
        @document
      end

      # uses the CSSMin gem to minify a CSS document using regular expressions
      def filter_minify
        @document = CSSMin.minify(document)
      end

    end
  end
end