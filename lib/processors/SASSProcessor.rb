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
    require 'extensions/Silently'

    require 'rubygems'

    # since the haml gem gives exec() warnings, we temporarily lower the verbosity
    # last tested with 2.2.14
    silently { require 'haml' }

    require 'processors/AbstractProcessor'
    require 'processors/CSSProcessor'

    class SASSProcessor < AbstractProcessor
      
    end
  end
end