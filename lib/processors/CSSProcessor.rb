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

    require 'processors/AbstractProcessor.rb'

    class CSSProcessor < AbstractProcessor

      def self.process(filename)
        css = CSSProcessor.new()
        css.open_resource(filename)
      end

      def self.file_patterns
        [".css"]
      end

      # setup a link to a CSS file
      def open_resource(filename)
        self.document = File.read(filename)
        self.original_size = File.size(filename)
        self.resource_name = filename

        return self
      end

      # uses the CSSMin gem to minfy a CSS document using regular expressions
      def filter_minify
        self.document = CSSMin.minify(document)
        self.processed_size = document.length
      end

      # TODO: the real fun begins when we integrate HTML and CSS minification
      # using shorter ID names, etc.

      # gives
      def generate
        run_filter :minify
        return document
      end
    end
  end
end