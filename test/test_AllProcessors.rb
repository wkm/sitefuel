#
# File::       test_AllProcessors.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Programmatic tests run against all processors
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/SiteFuelRuntime'

include SiteFuel

class TestAllProcessors < Test::Unit::TestCase

  def setup
    SiteFuelRuntime.load_processors
    @processors = SiteFuelRuntime.
      find_processors.
      delete_if do |proc|
        proc.to_s =~ /.*Test.*Processor/
      end
  end

  # ensure that every filter in every filter set is known
  def test_filter_sets
    @processors.each do |proc|
      proc.filtersets.each do |filterset|
        proc.filters_in_filterset(filterset).each do |filter|
          assert(
            proc.filter?(filter),
            'Filter %s in filterset %s isn\'t known for %s' %
            [filter, filterset, proc]
          )
        end
      end
    end
  end

  def test_default_filter_sets
    @processors.each do |proc|
      assert proc.filterset?(proc.default_filterset), 'Default filterset %s for %s isn\'t known'%[proc.default_filterset, proc]
    end
  end
end