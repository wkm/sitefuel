#
# File::       test_SymbolComparisons.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the spaceship method and hence sorting of symbols
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/extensions/SymbolComparison'

class TestSymbolComparisons < Test::Unit::TestCase
  def test_spaceship
    assert_equal(-1, :a<=>:b)
    assert_equal  0, :a<=>:a
    assert_equal  1, :b<=>:a

    assert_equal(-1, :a<=>:ab)
  end

  def test_sort
    assert_equal [:a, :b, :c], [:c, :a, :b].sort
  end
end