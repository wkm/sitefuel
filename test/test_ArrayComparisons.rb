#
# File::       test_ArrayComparisons.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the Array#ends_with? method.
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mixins/ArrayComparisons'

class TestArrayComparisons < Test::Unit::TestCase
  def test_ends_with

    # positive tests
    assert [1, 2, 3].ends_with?([2,3])
    assert [1, 2, 3].ends_with?([])
    assert [1, 2, 3].ends_with?([1, 2, 3])

    assert [].ends_with?([])
    assert [1].ends_with?([1])

    # negative tests
    assert ![1, 2, 3].ends_with?([1, 2])
    assert ![].ends_with?([1])
    assert ![1, 2, 3].ends_with?([1, 2, 3, 4])
    
  end
end