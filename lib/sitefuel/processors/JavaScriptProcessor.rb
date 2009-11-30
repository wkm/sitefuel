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

    require 'sitefuel/processors/AbstractProcessor'

    class JavaScriptProcessor < AbstractStringBasedProcessor

      def self.file_patterns
        ['.js']
      end
      
      # override AbstractProcessor#processor_name so output shows up as +JS+
      # instead of +JavaScript+.
      def processor_name
        "JS"
      end

      def default_filterset
        :minify
      end

      def filterset_minify
        [:minify]
      end

      def filter_minify
        @document = JSMin.minfy(@document)
      end

    end
  end
end