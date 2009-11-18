#
# File::       HTMLProcessorTest.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the HTMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','source')

require 'test/unit'
require 'processors/HTMLProcessor.rb'

include SiteFuel::Processor

class HTMLProcessorTest < Test::Unit::TestCase
  def test_file_extensions # hello
    html = HTMLProcessor.new

    # negative tests
    assert_equal false, html.processes_file?("testhtml")
    assert_equal false, html.processes_file?("testhtm")
    assert_equal false, html.processes_file?("testHTML")

    # positive tests
    assert html.processes_file?("test.html")
    assert html.processes_file?("test.htm")
    assert html.processes_file?("test.HTML")
    assert html.processes_file?("test.HtMl")
    assert html.processes_file?("test.hTm")
    
  end
end
