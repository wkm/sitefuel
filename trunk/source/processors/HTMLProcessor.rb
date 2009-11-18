#
# File::      HTMLProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Defines an HTMLProcessor class that is used to compress and cleanup HTML
# files for deployment with sitefuel. Uses hpricot to process the HTML.
#

module SiteFuel
  module Processor

    require 'rubygems'
    require 'hpricot'

    require 'processors/AbstractProcessor.rb'

    class HTMLProcessor < AbstractProcessor

      attr_accessor :document
      attr_reader :originalsize, :processedsize, :resourcename

      def self.process(filename)
        HTMLProcessor.new(filename)
      end

      def initialize(filename)
        @document = open(filename) { |f| Hpricot(f, :fixup_tags => true) }
        @originalsize = File.size(filename)
        @resoucename = filename
      end

      def stripwhitespace
        return if @document == nil

        @document.traverse_text do |txt|
          if txt.content =~ /^\s+$/ then
            txt.content = ''
          else
            txt.content = txt.content.gsub(/\s+/, ' ')
          end
        end
      end

      # beautify text by 
      def beautifytext
        beautifyquotes
        beautifydashes
      end

      def generate
        stripwhitespace
        text = @document.to_s
        @processedsize = text.length
        return text
      end
    end

  end
end