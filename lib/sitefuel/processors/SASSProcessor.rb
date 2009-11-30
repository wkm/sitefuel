#
# File::       SASSProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# processes .sass stylesheets to generate the associated CSS
#

module SiteFuel
  module Processor
    require 'rubygems'

    require 'sitefuel/extensions/Silently'

    # since the haml gem gives exec() warnings, we temporarily lower the verbosity
    # (last tested with 2.2.14, this might not be needed with a future version)
    silently { require 'haml' }

    require 'sitefuel/processors/AbstractProcessor'

    class SASSProcessor < AbstractProcessor
      
      def self.default_filterset
        :generate
      end

      def self.filterset_generate
        []
      end

    end
  end
end