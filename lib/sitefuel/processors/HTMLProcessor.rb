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

    require 'sitefuel/processors/AbstractStringBasedProcessor'

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


      # list of tags which have proper text items inside them
      TEXTUAL_TAGS             = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']
      
      # filter for use with XPath searches
      TEXTUAL_TAGS_FILTER      = TEXTUAL_TAGS.join('|')



      # gives the file patterns which this processor will match
      def self.file_patterns
        # TODO: add rhtml, php, etc.
        [".html", ".htm"]
      end

      def self.default_filterset
        :beautify
      end

      def self.filterset_minify
        [:whitespace, :minify_javascript, :minify_styles]
      end

      def self.filterset_beautify
        [:beautify_quotes, :beautify_dashes, :beautify_arrows]
      end


      #
      # FILTERS
      #

      # before any filters are run parse the document with hpricot
      def setup_filters
        @htmlstruc = Hpricot.parse(document)
      end

      # after all the filters are run dump the HTML as a string and do a
      # tiny bit of post processing
      def finish_filters
        # do a last minute, ugly +br+ cleanup
        @document = @htmlstruc.to_s.gsub('<br />', '<br>')
      end

      def traverse(patterns = TEXTUAL_TAGS_FILTER, &block)
        (@htmlstruc/patterns).each do |tag|
          tag.traverse_text do |txt|
            block.call(tag.pathname, txt)
          end
        end
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

      # minifies embedded JavaScript code
      def filter_minify_javascript

      end

      # minifies embedded CSS styles
      def filter_minify_styles
        
      end

      # cleans up double and single quotes in textual objects
      # <pre>"hello world"  =>  &#8220; hello world&#8221;</pre>
      def filter_beautify_quotes
        traverse do |tag,txt|
          txt.content = txt.content.
            # apostrophes
            gsub(/(\S)'(s)/i,   '\1%s\2' % SINGLE_QUOTE_CLOSE).
            gsub(/(\Ss)'(\s)/i,     '\1%s\2'   % SINGLE_QUOTE_CLOSE).

            # double quotes
            gsub(/"(\S.*?\S)"/, '%s\1%s' % [DOUBLE_QUOTE_OPEN, DOUBLE_QUOTE_CLOSE]).

            # single quotes
            gsub(/'(\S.*?\S)'/, '%s\1%s' % [SINGLE_QUOTE_OPEN, SINGLE_QUOTE_CLOSE])
        end
      end

      # cleans up the various dash forms:
      # <pre>12--13  =>  12&#8211;13</pre>
      # <pre>the car---it was red---was destroyed  =>  ...&#8212;it was red&#8212;...</pre>
      def filter_beautify_dashes
        # TODO en-dashes between two numbers
        # TODO em-dashes between words
        # ...
      end

      def filter_beautify_arrows
        traverse do |tag,txt|
          txt.content = txt.content.
            gsub(/\b-->\b/, ARROW_RIGHTWARD).
            gsub(/\b<--\b/, ARROW_LEFTWARD).
            gsub(/\b<->\b/, ARROW_LEFTRIGHT).
            gsub(/\b==>\b/, ARROW_DOUBLE_RIGHTWARD).
            gsub(/\b<==\b/, ARROW_DOUBLE_LEFTWARD).
            gsub(/\b<=>\b/, ARROW_DOUBLE_LEFTRIGHT)
        end
      end

    end
  end
end