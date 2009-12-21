#
# File::      test_StringFormatting.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for String#cabbrev, String#labbrev, and String#rabbrev
# methods. The main thing these look for is off-by-one errors.
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'term/ansicolor'

include Term::ANSIColor

require 'test/unit'
require 'sitefuel/extensions/StringFormatting'

class TestString < Test::Unit::TestCase
  def test_cabbrev
    assert_equal "hello world", "hello world".cabbrev(11)
    assert_equal "hello world", "hello world".cabbrev(12)

    assert_equal 12, "the quick brown fox jumped over the lazy dog".cabbrev(12).length
    assert_equal "the q... dog", "the quick brown fox jumped over the lazy dog".cabbrev(12)
    assert_equal "the quick brown fox... over the lazy dog", "the quick brown fox jumped over the lazy dog".cabbrev(40)
  end

  def test_rabbrev
    assert_equal "foo", "foo".rabbrev(12)

    assert_equal "...brown dog", "the quick brown dog".rabbrev(12)
    assert_equal 12, "the quick brown dog".rabbrev(12).length
  end

  def test_labbrev
    assert_equal "foo", "foo".labbrev(12)

    assert_equal "the quick...", "the quick brown dog".labbrev(12)
    assert_equal 12, "the quick brown dog".labbrev(12).length
  end

  def test_align
    assert_equal(
      "hi\n  hello world\nyup there\n  it is!\n",
      %q{
        hi
          hello world
        yup there
          it is!
      }.align
    )
  end

  def test_visual_length
    assert_equal(
      'hello world'.length,
      'hello world'.visual_length
    )

    assert_equal(
      'hello world'.length,
      'hello world'.blue.visual_length
    )
  end

  def test_visual_ljust
    assert_equal(
      '123'.ljust(5),
      '123'.blue.visual_ljust(5).uncolored
    )
  end
end
