#
# File::      JavaScriptProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  module Processor
    require 'rubygems'
    require 'jsmin'

    require 'processors/AbstractProcessor.rb'

    class JavaScriptProcessor < AbstractProcessor
      attr_accessor :document

      def self.process(filename)
        js = JavaScriptProcessor.new
        js.document = File.read(filename)

        return js
      end

      # use the +JSMin+ library to compact a javascript file
      def compact
        @document = JSMin.minify(@document)
      end

      # override AbstractProcessor#processor_name so output shows up as +JS+
      # instead of +JavaScript+.
      def processor_name
        "JS"
      end

      def generate
        return @document
      end

    end
  end
end