#
# File::        test_SiteFuelRuntime.m
# Author::      wkm
# Copyright::   2009
# License::     GPL
#
# Unit tests for the SiteFuelRuntime class.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'SiteFuelRuntime'

include SiteFuel

class HTMLClasherTest < Processor::AbstractProcessor
  def self.file_patterns
    [".html"]
  end
end

class TestSiteFuelRuntime < Test::Unit::TestCase

  def setup
    @runtime = SiteFuelRuntime.new
  end

  def test_processor_picking
    assert_equal Processor::CSSProcessor, @runtime.choose_processor("foo.css")

    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("foo.html")
    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("FOO.HtM")

    assert_nil @runtime.choose_processor("foo.xxxx")
    assert_nil @runtime.choose_processor("foocss")
    assert_nil @runtime.choose_processor("foohtml")
  end

  def test_processor_finding
    # test that we don't have the clasher, since it doesn't end with Processor
    assert !SiteFuelRuntime.find_processors.include?(HTMLClasherTest), 'HTMLClasherTest included'

    # test that we do have the basic processor test suite
    assert SiteFuelRuntime.find_processors.include?(Processor::HTMLProcessor)
    assert SiteFuelRuntime.find_processors.include?(Processor::CSSProcessor)
    assert SiteFuelRuntime.find_processors.include?(Processor::SassProcessor)
  end

  def test_processor_clashing
    @runtime.add_processor(HTMLClasherTest)
    
    assert_raise Processor::MultipleApplicableProcessors do
      @runtime.choose_processor("foo.html")
    end

    assert_nothing_raised do
      @runtime.choose_processor!("foo.html")
    end

    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("foo.htm")

  end
end