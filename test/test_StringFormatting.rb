$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mixins/StringFormatting'

class TestString < Test::Unit::TestCase
  def test_abbrev
    assert_equal "hello world", "hello world".cabbrev(11)
    assert_equal "hello world", "hello world".cabbrev(12)

    assert_equal 12, "the quick brown fox jumped over the lazy dog".cabbrev(12).length
    assert_equal "the q... dog", "the quick brown fox jumped over the lazy dog".cabbrev(12)
    assert_equal "the quick brown fox... over the lazy dog", "the quick brown fox jumped over the lazy dog".cabbrev(40)
  end
end
