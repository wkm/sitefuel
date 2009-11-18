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
      attr_reader :original_size, :processed_size, :resource_name

      def self.process(filename)
        html = HTMLProcessor.new
        html.open_resource(filename)
      end

      def open_resouce(filename)
        @document = open(filename) { |f| Hpricot(f, :fixup_tags => true) }
        @original_size = File.size(filename)
        @resouce_name = filename
      end

      # gives the file patterns which this processor will match
      def file_patterns
        # TODO: add rhtml, php, etc.
        [".html", ".htm"]
      end

      def filter_whitespace
        return if @document == nil

        @document.traverse_text do |txt|
          if txt.content =~ /^\s+$/ then
            txt.content = ''
          else
            txt.content = txt.content.gsub(/\s+/, ' ')
          end
        end
      end

      def filter_beautifytext
        run_filter :beautifyquotes
        run_filter :beautifydashes
      end

      # cleans up all the quotes in
      def filter_beautifyquotes
      end

      # cleans up the various dash forms:
      #
      #  a = {:a => 1, :b => 2}
      def filter_beautifydashes
        
      end

      def generate
        run_filter :whitespace
        text = @document.to_s
        @processed_size = text.length
        return text
      end
    end

  end
end