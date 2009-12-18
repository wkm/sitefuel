#
# File::      PHPProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
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
        # it doesn't really make sense to handle phps files, so we're leaving
        # them alone. It might make sense to have a dummy empty processor for
        # the files so it's clear we recognize them.
        ['.php', '.phtml', '.php5']
      end

    end

  end
end
