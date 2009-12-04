#
# File::       test_PHPProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the PHPProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/PHPProcessor'

include SiteFuel::Processor

class TestPHPProcessor < Test::Unit::TestCase

  def test_file_extensions
    assert PHPProcessor.processes_file?('test.php')
    assert PHPProcessor.processes_file?('test.php5')
    assert PHPProcessor.processes_file?('test.phps')
    assert PHPProcessor.processes_file?('test.phtml')
  end

  def test_name
    assert_equal 'PHP', PHPProcessor.processor_name
  end
  
end