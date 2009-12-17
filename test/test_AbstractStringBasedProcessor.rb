#
# File::      test_AbstractStringBasedProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Unit tests for the string-based processor abstraction
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'tempfile'
require 'sitefuel/processors/AbstractStringBasedProcessor'

include SiteFuel::Processor

class StringProc1 < AbstractStringBasedProcessor
  def self.default_filterset
    :typical
  end

  def self.filterset_typical
    [:test]
  end

  def filter_test
    @document = @document.gsub('hello', 'goodbye')
  end

end

class TestAbstractStringBasedProcessor < Test::Unit::TestCase
  def test_processor_type
    assert 'String', StringProc1.processor_type
  end

  def test_process_file
    # create a test file to process
    tf = Tempfile.new('abstract-string-based-processor.txt')
    File.open(tf.path, 'w') do |f|
      f.write('hello world')
    end

    proc = StringProc1.process_file(tf.path)
    assert_equal 'goodbye world', proc.document
  end
end