#
# File::      PNGProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Interfaces with the rbcrush library that's wrapped around pngcrush
#

module SiteFuel
  module Processor

    require 'processors/AbstractProcessor'

    # processor for handling Portable Network Graphics images
    # currently operates as a lightweight wrapper around 'pngcrush'
    class PNGProcessor < AbstractProcessor
      def file_patterns
        ['.png']
      end
    end

  end
end