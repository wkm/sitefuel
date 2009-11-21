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

    require 'processors/AbstractProcessor.rb'
    require 'processors/CSSProcessor.rb'

    class SassProcessor < AbstractProcessor
      
    end
  end
end