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

    require 'processors/AbstractStringBasedProcessor'

    class HTMLProcessor < AbstractStringBasedProcessor

      # gives the file patterns which this processor will match
      def self.file_patterns
        # TODO: add rhtml, php, etc.
        [".html", ".htm"]
      end

      def default_filterset
        :minify
      end

      def filterset_minify
        [:minify]
      end

      def filterset_beautify
        [:beautifytext, :beautifyquotes, :beautifydashes]
      end


      #
      # FILTERS
      #

      def filter_whitespace
        return if document == nil

        document.traverse_text do |txt|
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
      def filter_beautifydashes
        
      end

    end
  end
end