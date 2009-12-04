#
# File::      PHPProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Defines a PHPProcessor class; but it's really a very lightweight alias
# around the HTMLProcessor
#


module SiteFuel
  module Processor

    require 'sitefuel/processors/HTMLProcessor'

    # An alias for the HTMLProcessor; there is nothing PHP specific
    # sitefuel can do at the moment.
    class PHPProcessor < HTMLProcessor

      # PHP specific file patterns
      def self.file_patterns
        ['.php', '.phtml', '.php3']
      end

    end

  end
end
