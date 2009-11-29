#
# File::       test_StringFormatting.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for String#cabbrev, String#labbrev, and String#rabbrev
# methods. The main thing these look for is off-by-one errors.
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'extensions/StringFormatting'

module SiteFuel
  module Test


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
    end
    
  end
end