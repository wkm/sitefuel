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
      def processor_name
        "JS"
      end

      def self.default_filterset
        :minify
      end

      def self.filterset_minify
        [:minify]
      end

      def filter_minify
        @document = JSMin.minify(@document).strip
      end

    end
  end
end