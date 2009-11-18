#
# File::       test_AbstractProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the AbstractProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'processors/AbstractProcessor.rb'

include SiteFuel::Processor

class TestProcessorA < AbstractProcessor
  def filter_a; end
  def filter_b; end
  def filter_c; end
  def filter_long_name; end
end

class TestProcessorB < AbstractProcessor
end

class TestAbstractProcessor < Test::Unit::TestCase
  def test_filters
    ta = TestProcessorA.new

    assert_equal [:a, :b, :c, :long_name], ta.filters
    assert_nil ta.run_filter(:a)
    assert_nil ta.run_filter(:b)
    assert_nil ta.run_filter(:long_name)

    assert_raise UnknownFilter do
      ta.run_filter(:foo)
    end
  end
end
