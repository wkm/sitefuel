#
# File::       test_HTMLProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the HTMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'processors/HTMLProcessor'


module SiteFuel
  module Test

    include SiteFuel::Processor

    class TestHTMLProcessor < Test::Unit::TestCase
      def test_file_extensions

        # negative tests
        assert_equal false, HTMLProcessor.processes_file?("testhtml")
        assert_equal false, HTMLProcessor.processes_file?("testhtm")
        assert_equal false, HTMLProcessor.processes_file?("testHTML")

        assert_equal false, HTMLProcessor.processes_file?("test.html.foo")
        assert_equal false, HTMLProcessor.processes_file?("test.htm.foo")

        # positive tests
        assert HTMLProcessor.processes_file?("test.html")
        assert HTMLProcessor.processes_file?("test.htm")
        assert HTMLProcessor.processes_file?("test.HTML")
        assert HTMLProcessor.processes_file?("test.HtMl")
        assert HTMLProcessor.processes_file?("test.hTm")

      end

      def test_name
        assert_equal "HTML", HTMLProcessor.processor_name
      end
    end
    
  end
end