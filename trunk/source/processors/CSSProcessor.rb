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

      def self.process(filename)
        css = CSSProcessor.new
        css.document = File.read(filename)

        return css
      end

      def compact
        @document = CSSMin.minify(@document)
      end

      def generate
        return @document
      end

    end
    
  end
end