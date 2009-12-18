#
# File::      RHTMLProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL
#
# Defines the RHTMLProcessor class. This is a lightweight wrapper
# around the HTMLProcessor class
#

module SiteFuel
  module Processor
    require 'sitefuel/processors/HTMLProcessor'

    class RHTMLProcessor < HTMLProcessor

      def self.file_patterns
        ['.rhtml', '.erb']
      end


    end

  end
end