#
# File::      JavaScriptProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#

module SiteFuel
  module Processor
    
    require 'jsmin'

    require 'sitefuel/processors/AbstractStringBasedProcessor'

    class JavaScriptProcessor < AbstractStringBasedProcessor

      def self.file_patterns
        ['.js']
      end
      
      # override AbstractProcessor#processor_name so output shows up as +JS+
      # instead of +JavaScript+.
      def self.processor_name
        "JS"
      end

      def self.default_filterset
        :minify
      end

      def self.filterset_minify
        [:minify]
      end

      CDATA_START = '//<![CDATA['
      CDATA_END   = '//]]>'
      def filter_minify
        return nil if @document == nil
        return nil if @document.length == 0

        # JSMin doesn't like having files without any newlines
        @document << "\n"

        # put in CDATA placeholders
        @document.gsub!(CDATA_START, '[[CDATA_START]]')
        @document.gsub!(CDATA_END,   '[[CDATA_END]]')

        # run the minification
        @document = JSMin.minify(@document).strip

        # put back CDATA
        @document.gsub!('[[CDATA_START]]', CDATA_START)
        @document.gsub!('[[CDATA_END]]',   CDATA_END)
      end
    end
  end
end