#
# File::       test_AbstractProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the AbstractProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'processors/AbstractProcessor.rb'

include SiteFuel::Processor

class TestAProcessor < AbstractProcessor
  def filter_a; end
  def filter_b; end
  def filter_c; end
  def filter_long_name; end

  def file_patterns
    [".testA", ".test-a", ".test.a", "_test_a"]
  end
end

class TestBProcessor < AbstractProcessor
  def file_patterns
    [/tpb.*fitz/, ".tpb"]
  end
end

class TestAbstractProcessor < Test::Unit::TestCase
  def setup
    @ta = TestAProcessor.new
    @tb = TestBProcessor.new
  end

  def test_filters
    assert_equal [:a, :b, :c, :long_name], @ta.filters
    assert_nil @ta.run_filter(:a)
    assert_nil @ta.run_filter(:b)
    assert_nil @ta.run_filter(:long_name)

    assert_raise UnknownFilter do
      @ta.run_filter(:foo)
    end

    assert_equal [], @tb.filters
  end

  def test_file_patterns_01
    assert @ta.processes_file?(".testA")
    assert @ta.processes_file?(".test-a")
    assert @ta.processes_file?(".test.a")
    assert @ta.processes_file?("_test_a")

    assert @ta.processes_file?("foo.testA")
    assert @ta.processes_file?("foo.testa")
    assert @ta.processes_file?("foo.test-a")
    assert @ta.processes_file?("foo.test.a")
    assert @ta.processes_file?("foo_test_a")

    assert_equal false, @ta.processes_file?("footestA")
    assert_equal false, @ta.processes_file?(":")
    assert_equal false, @ta.processes_file?("testA")
    assert_equal false, @ta.processes_file?("XtestA")
    assert_equal false, @ta.processes_file?("XtestXA")
  end

  def test_file_patterns_02
    # file extension tests
    assert @tb.processes_file?("test.tpb")
    assert @tb.processes_file?("foo.tpb")

    # regexp file name test
    assert @tb.processes_file?("tpb.foofoofitz")
    assert_equal false, @tb.processes_file?("TPB.foofoofitz")
  end

  def test_processor_names
    assert_equal "TestA", @ta.processor_name
    assert_equal "TestB", @tb.processor_name
  end
end
