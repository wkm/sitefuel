#
# File::      JavaScriptProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
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
        @document.gsub!(CDATA_START, '[[CDATA_START]]').
                  gsub!(CDATA_END,   '[[CDATA_END]]')

        @document = JSMin.minify(@document).strip

        @document.gsub!('[[CDATA_START]]', CDATA_START).
                  gsub!('[[CDATA_END]]',   CDATA_END)
      end

    end
  end
end