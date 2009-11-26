#
# File::      CSSProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  module Processor

    require 'rubygems'
    require 'cssmin'

    require 'processors/AbstractStringBasedProcessor'

    class CSSProcessor < AbstractStringBasedProcessor

      # file patterns for CSS
      def self.file_patterns
        [".css"]
      end

      #
      # FILTER SETS
      #

      # gives the default filterset to run
      def default_filterset
        :minify
      end

      # gives the minify filter to run
      def filterset_minify
        [:minify]
      end

      #
      # FILTERS
      #

      # lightweight whitespace crusher; removed excess whitespace, etc.
      def filter_crush_whitespace
        
      end

      # lightweight CSS beautifier based on Regexp
      def filter_beautify

      end

      # uses the CSSMin gem to minfy a CSS document using regular expressions
      def filter_minify
        document = CSSMin.minify(document)
      end

    end
  end
end