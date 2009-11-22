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
    require 'haml'

    require 'processors/AbstractProcessor'
    require 'processors/CSSProcessor'

    class SassProcessor < AbstractProcessor
      
    end
  end
end