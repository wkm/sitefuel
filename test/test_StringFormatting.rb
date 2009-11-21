$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mixins/StringFormatting.rb'

class TestString < Test::Unit::TestCase
  def test_abbrev
    assert_equal "hello world", "hello world".abbrev(11)
    assert_equal "hello world", "hello world".abbrev(12)

    assert_equal 12, "the quick brown fox jumped over the lazy dog".abbrev(12).length
    assert_equal "the q... dog", "the quick brown fox jumped over the lazy dog".abbrev(12)
    assert_equal "the quick brown fox... over the lazy dog", "the quick brown fox jumped over the lazy dog".abbrev(40)
  end
end
