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
require 'processors/CSSProcessor.rb'

include SiteFuel::Processor

class TestCSSProcessor < Test::Unit::TestCase
  def test_file_extensions
    css = CSSProcessor.new

    # negative tests
    assert_equal false, css.processes_file?("testcss")
    assert_equal false, css.processes_file?("test.css.foo")

    # positive tests
    assert css.processes_file?("test.css")
    assert css.processes_file?("test.CSS")
    assert css.processes_file?("test.CsS")
  end

  def test_name
    css = CSSProcessor.new
    assert_equal "CSS", css.processor_name
  end
end
