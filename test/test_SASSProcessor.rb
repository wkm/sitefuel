#
# File::       test_SASSProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the SASSProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/extensions/StringFormatting'
require 'sitefuel/processors/SASSProcessor'

include SiteFuel::Processor

class TestSASSProcessor < Test::Unit::TestCase
  def test_file_extensions

    # negative tests
    assert_equal false, SASSProcessor.processes_file?("testsass")

    # positive tests
    assert SASSProcessor.processes_file?("test.sass")
    assert SASSProcessor.processes_file?("test.SASS")

  end

  def test_name
    assert_equal "SASS", SASSProcessor.processor_name
  end

  def test_generate
    assert_equal(
      %q{
        #main {
          background-color: #ff0000;
          width: 98%; }
      }.align.strip,

      SASSProcessor.filter_string(:generate,
        %q{
          // from the SASS documentation
          #main
            background-color: #ff0000
            width: 98%
        }.align
      ).strip
    )
  end

  def test_minify
    assert_equal(
      "#main{background-color:#f00;width:98%;}",

      SASSProcessor.filter_string([:generate, :minify],
        %q{
          // from the SASS documentation
          #main
            background-color: #ff0000
            width: 98%
        }.align
      ).strip
    )
  end

end
