#
# File::       sassprocessor.rb
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

    require 'processors/abstractprocessor.rb'
    require 'processors/cssprocessor.rb'

    class SassProcessor < AbstractProcessor
      
    end
  end
end