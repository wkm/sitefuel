#
# File::       test_RHTMLProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the RHTMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/RHTMLProcessor'

include SiteFuel::Processor

class TestRHTMLProcessor < Test::Unit::TestCase

  def test_file_extensions
    assert RHTMLProcessor.processes_file?('test.rhtml')
    assert RHTMLProcessor.processes_file?('test.erb')
  end

  def test_name
    assert_equal 'RHTML', RHTMLProcessor.processor_name
  end

end