#
# File::      HTMLProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Defines an HTMLProcessor class that is used to compress and cleanup HTML
# files for deployment with sitefuel. Uses nokogiri to process the HTML.
#


require 'nokogiri'

class Nokogiri::XML::Node
  # implements the #traverse_text method from hpricot
  def traverse_text(&block)
    children.each do |node|
      if node.text?
        block.call(node)
      end
    end
  end
end

class Fixnum
  # gives the UTF-8 encoded charcter corresponding to this unicode number
  def utf8
    [self].pack('U*')
  end
end

module SiteFuel
  module Processor

    require 'sitefuel/processors/AbstractStringBasedProcessor'
    require 'sitefuel/processors/CSSProcessor'
    require 'sitefuel/processors/JavaScriptProcessor'

    class HTMLProcessor < AbstractStringBasedProcessor
      HTML_PARSE_OPTIONS       = Nokogiri::XML::ParseOptions::NOERROR |
                                 Nokogiri::XML::ParseOptions::NOWARNING |
                                 Nokogiri::XML::ParseOptions::NONET |
                                 Nokogiri::XML::ParseOptions::RECOVER
      HTML_DOCUMENT            = Nokogiri::HTML.parse("", nil, "ASCII", HTML_PARSE_OPTIONS)

      #
      # HTML ENTITIES
      #

      # quotes
      SINGLE_QUOTE_OPEN        = 8216.utf8.freeze
      SINGLE_QUOTE_CLOSE       = 8217.utf8.freeze
      DOUBLE_QUOTE_OPEN        = 8220.utf8.freeze
      DOUBLE_QUOTE_CLOSE       = 8221.utf8.freeze

      # dashes
      EN_DASH                  = 8211.utf8.freeze
      EM_DASH                  = 8212.utf8.freeze

      # signs
      ELLIPSIS                 = 8230.utf8.freeze
      COPYRIGHT                =  169.utf8.freeze
      TRADEMARK                = 8482.utf8.freeze
      REGISTERED               =  174.utf8.freeze

      # arrows
      ARROW_LEFTWARD           = 8592.utf8.freeze
      ARROW_RIGHTWARD          = 8594.utf8.freeze
      ARROW_LEFTRIGHT          = 8596.utf8.freeze
      ARROW_DOUBLE_LEFTWARD    = 8656.utf8.freeze
      ARROW_DOUBLE_RIGHTWARD   = 8658.utf8.freeze
      ARROW_DOUBLE_LEFTRIGHT   = 8660.utf8.freeze

      # math operators
      MULTIPLICATION_SIGN      =  215.utf8.freeze


      # list of tags which have proper text items inside them
      TEXTUAL_TAGS             = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6',
                                  'p', 'b', 'i', 'ul', 'a', 'li', 'td',
                                  'th'].freeze
      
      # filter for use with XPath searches
      TEXTUAL_TAGS_FILTER      = TEXTUAL_TAGS.join('|').freeze



      # gives the file patterns which this processor will match
      def self.file_patterns
        [
          # plain html
          ".html", ".htm"

          # other basically-HTML formats like RHTML have their own
          # lightweight processor which inherit HTMLProcessor.
        ]
      end


      def self.default_filterset
        :minify
      end


      def self.filterset_minify
        [:whitespace, :minify_javascript, :minify_styles]
      end


      def self.filterset_beautify
        [:beautify_quotes, :beautify_dashes, :beautify_arrows, :beautify_symbols]
      end

      #
      # FILTERS
      #

      # before any filters are run parse the document with nokogiri
      def setup_filters
        # use HTML_DOCUMENT to set the encoding to ASCII; this needs to be
        # robustified to deal with non-ASCII encodings, however.
        @htmlstruc = Nokogiri::HTML::DocumentFragment.new(HTML_DOCUMENT, document)
      end


      # after all the filters are run dump the HTML as a string and do a
      # tiny bit of post processing
      def finish_filters
        # do a last minute, ugly +br+ cleanup
        @document = @htmlstruc.to_s
      end


      def traverse(patterns = TEXTUAL_TAGS_FILTER, &block)
        @htmlstruc.xpath(patterns).each do |tag|
          tag.traverse_text do |txt|
            block.call(tag.path, txt)
          end
        end
      end


      # strips excess whitespace in most HTML tags. Notably, +pre+ tags are
      # left alone.
      def filter_whitespace
        @htmlstruc.traverse_text do |txt|
          if /\A\s+\z/ =~ txt.raw_content then
            txt.raw_content = ''
          else
            txt.raw_content = txt.raw_content.gsub(/\s+/m, ' ')
          end
        end
      end


      # minifies embedded JavaScript code using the JavaScriptProcessor
      def filter_minify_javascript
        # TODO check the language attribute to make sure it's javascript
        traverse('script') do |_,txt|
          txt.content = JavaScriptProcessor.process_string(
                  txt.raw_content,
                  {:resource_name => resource_name+'<embedded_JS>'}
          )
        end
      end


      # minifies embedded CSS styles using the CSSProcessor
      def filter_minify_styles
        traverse('style') do |_,txt|
          txt.content = CSSProcessor.process_string(
                  txt.raw_content,
                  :resource_name => resource_name+'<embedded_CSS>'
          )
        end
      end


      # cleans up double and single quotes in textual objects
      # <pre>"hello world"  =>  &#8220; hello world&#8221;</pre>
      def filter_beautify_quotes
        traverse do |_,txt|
          txt.content = txt.content.
            # apostrophes
            gsub(/(\S)'(s)/i,   '\1%s\2' % SINGLE_QUOTE_CLOSE).
            gsub(/(\Ss)'(\s)/i, '\1%s\2'   % SINGLE_QUOTE_CLOSE).

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
        traverse do |_,txt|
          txt.content = txt.content.
            # between two numbers we have an en dash
            # this would be a bit cleaner with (negative) lookbehind
            gsub(/(\d)--(\d)/,        "\\1#{EN_DASH}\\2").

            # we can also have multiple en-dashes
            gsub(/\b(--(--)+)(\b|\z|\s)/) do ||
              EN_DASH * ($1.length / 2) + $3
            end.

            # three dashes in general are an em dash
            gsub(/(\s|\b)---(\s|\b)/, "\\1#{EM_DASH}\\2")
        end
      end


      # convert basic arrow forms to unicode characters
      def filter_beautify_arrows
        traverse do |_,txt|
          txt.content = txt.content.
            gsub(/(\s|\b)--&gt;(\s|\b)/, "\\1#{ARROW_RIGHTWARD}\\2").
            gsub(/(\s|\b)&lt;--(\s|\b)/, "\\1#{ARROW_LEFTWARD}\\2").
            gsub(/(\s|\b)&lt;-&gt;(\s|\b)/, "\\1#{ARROW_LEFTRIGHT}\\2").
            gsub(/(\s|\b)==&gt;(\s|\b)/, "\\1#{ARROW_DOUBLE_RIGHTWARD}\\2").
            gsub(/(\s|\b)&lt;==(\s|\b)/, "\\1#{ARROW_DOUBLE_LEFTWARD}\\2").
            gsub(/(\s|\b)&lt;=&gt;(\s|\b)/, "\\1#{ARROW_DOUBLE_LEFTRIGHT}\\2")
        end
      end


      # converts 'x' signs between numbers into the unicode symbol
      def filter_beautify_math

      end

      
      # convert a few shorthands like (c), (tm) to their unicode symbols
      def filter_beautify_symbols
        traverse do |_,txt|
          txt.content = txt.content.
            gsub(/\(tm\)/i, TRADEMARK).
            gsub(/\(c\)/i,  COPYRIGHT).
            gsub(/\(r\)/i,  REGISTERED).
            gsub(/(\b| )\.\.\.(\.)?/, "\\1#{ELLIPSIS}\\2")

        end
      end

    end
  end
end