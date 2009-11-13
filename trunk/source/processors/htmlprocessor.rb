#
# File::      htmlprocessor.rb
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

    require 'processors/abstractprocessor.rb'

    class HTMLProcessor < AbstractProcessor

      attr_accessor :document

      def self.process(filename)
        html = HTMLProcessor::new()
        html.document = open(filename) { |f| Hpricot(f, :fixup_tags => true) }

        return html
      end

      # Strips the whitespace out of a loaded HTML document.
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

      def generate
        @document.to_s
      end
    end

  end
end