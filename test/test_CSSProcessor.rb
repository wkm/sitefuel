#
# File::       test_CSSProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the CSSProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'processors/CSSProcessor'

include SiteFuel::Processor

class TestCSSProcessor < Test::Unit::TestCase
  def test_file_extensions
    
    # negative tests
    assert_equal false, CSSProcessor.processes_file?("testcss")
    assert_equal false, CSSProcessor.processes_file?("test.css.foo")

    # positive tests
    assert CSSProcessor.processes_file?("test.css")
    assert CSSProcessor.processes_file?("test.CSS")
    assert CSSProcessor.processes_file?("test.CsS")
  end

  def test_name
    assert_equal "CSS", CSSProcessor.processor_name
  end
end
