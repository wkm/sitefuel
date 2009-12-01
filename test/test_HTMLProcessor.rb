#
# File::       test_HTMLProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the HTMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/HTMLProcessor'

include SiteFuel::Processor

class TestHTMLProcessor < Test::Unit::TestCase
  def test_file_extensions
    
    # negative tests
    assert_equal false, HTMLProcessor.processes_file?("testhtml")
    assert_equal false, HTMLProcessor.processes_file?("testhtm")
    assert_equal false, HTMLProcessor.processes_file?("testHTML")

    assert_equal false, HTMLProcessor.processes_file?("test.html.foo")
    assert_equal false, HTMLProcessor.processes_file?("test.htm.foo")

    # positive tests
    assert HTMLProcessor.processes_file?("test.html")
    assert HTMLProcessor.processes_file?("test.htm")
    assert HTMLProcessor.processes_file?("test.HTML")
    assert HTMLProcessor.processes_file?("test.HtMl")
    assert HTMLProcessor.processes_file?("test.hTm")
    
  end

  def test_name
    assert_equal "HTML", HTMLProcessor.processor_name
  end

  def test_beautify_quotes
    assert_equal(
      %q{<p>&#8220;Really?&#8221; Alice asked.<br>&#8220;Yes. Just yesterday.&#8221; said Bob.</p>},
      
      HTMLProcessor.filter_string(
        :beautify_quotes,
        %q{<p>"Really?" Alice asked.<br>"Yes. Just yesterday." said Bob.}
      )
    )

    assert_equal(
      %q{<p>This was Alice&#8217;s car; she bought it from the Hoovers.</p>},

      HTMLProcessor.filter_string(
        :beautify_quotes,
        %q{<p>This was Alice's car; she bought it from the Hoovers.</p>}
      )
    )
  end

  def test_beautify_arrows
    assert_equal(
      %q{<p>a &#8594; b &#8592; c &#8596; d</p>},

      HTMLProcessor.filter_string(
        :beautify_arrows,
        %q{<p>a --> b <-- c <-> d</p>}
      )
    )

    assert_equal(
      %q{<p>a &#8658; b &#8656; c &#8660; d</p>},
      
      HTMLProcessor.filter_string(
        :beautify_arrows,
        %q{<p>a ==> b <== c <=> d</p>}
      )
    )
  end

  def test_beautify_dashes

  end
end
