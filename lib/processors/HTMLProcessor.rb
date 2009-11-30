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

      #
      # HTML ENTITIES
      #

      # quotes
      SINGLE_QUOTE_OPEN        = '&#8216;'
      SINGLE_QUOTE_CLOSE       = '&#8217;'
      DOUBLE_QUOTE_OPEN        = '&#8220;'
      DOUBLE_QUOTE_CLOSE       = '&#8221;'

      # dashes
      EN_DASH                  = '&#8211;'
      EM_DASH                  = '&#8212;'

      # ellipsis
      ELLIPSIS                 = '&#8230;'

      # arrows
      ARROW_LEFTWARD           = '&#8592;'
      ARROW_RIGHTWARD          = '&#8594;'
      ARROW_LEFTRIGHT          = '&#8596;'
      ARROW_DOUBLE_LEFTWARD    = '&#8656;'
      ARROW_DOUBLE_RIGHTWARD   = '&#8658;'
      ARROW_DOUBLE_LEFTRIGHT   = '&#8660;'

      # math operators
      MULTIPLICATION_SIGN      = '&#215;'



      # gives the file patterns which this processor will match
      def self.file_patterns
        # TODO: add rhtml, php, etc.
        [".html", ".htm"]
      end

      def self.default_filterset
        :minify
      end

      def self.filterset_minify
        [:whitespace]
      end

      def self.filterset_beautify
        [:beautify_text, :beautify_quotes, :beautify_dashes]
      end


      #
      # FILTERS
      #

      # before any filters are run parse the document with hpricot
      def setup_filters
        @htmlstruc = Hpricot.parse(document, :fixtags)
      end

      # after all the filters are run dump the HTML as a string
      def finish_filters
        @document = @htmlstruc.to_s
      end

      def filter_whitespace
        @htmlstruc.traverse_text do |txt|
          if /\A\s+\z/ =~ txt.content then
            txt.content = ''
          else
            txt.content = txt.content.gsub(/\s+/m, ' ')
          end
        end
      end

      def filter_beautify_quotes
        
      end


      # cleans up double and single quotes in textual objects
      # <pre>"hello world"  =>  &#8220;hello world&#8221;</pre>
      def filter_beautifyquotes
      end

      # cleans up the various dash forms:
      # <pre>12--13  =>  12&#8211;13</pre>
      # <pre>the car---it was red---was destroyed  =>  ...&#8212;it was red&#8212;...</pre>
      def filter_beautifydashes
        
      end

    end
  end
end