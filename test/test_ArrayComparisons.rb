$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mixins/ArrayComparisons'

class TestArrayComparisons < Test::Unit::TestCase
  def test_ends_with
    
    assert [1, 2, 3].ends_with?([2,3])
    assert [1, 2, 3].ends_with?([])
    assert [1, 2, 3].ends_with?([1, 2, 3])
    assert ![1, 2, 3].ends_with?([1, 2])
    
  end
end