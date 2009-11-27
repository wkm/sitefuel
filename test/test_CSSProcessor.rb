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

  def test_minify
    # test: whitespace removal; hexcode compaction; comment stripping
    assert_equal "body{color:#000;}", CSSProcessor.filter_string(
      :minify,
      <<-END
        body {
          /* comments should be stripped */
          color: #000000;
        }
      END
    )

    # TODO need many more unit tests here; since it's based on CSSMin we might
    # just inherit those.
  end
end
