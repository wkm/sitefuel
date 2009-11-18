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
      attr_accessor :document
      attr_reader :original_size, :processed_size

      def self.process(filename)
        css = CSSProcessor.new()
        css.open_resource(filename)
      end

      def file_patterns
        [".css"]
      end

      # setup a link to a CSS file
      def open_resource(filename)
        @document = File.read(filename)
        @original_size = File.size(filename)
        @resource_name = filename
      end

      def filter_minify
        @document = CSSMin.minify(@document)
        @processed_size = @document.length
      end

      def generate
        compact
        return @document
      end

    end
  end
end