#
# File::      test_HAMLProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the HAMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/extensions/StringFormatting'
require 'sitefuel/processors/HAMLProcessor'

include SiteFuel::Processor

class TestHAMLProcessor < Test::Unit::TestCase
  def test_file_extensions

    # negative tests
    assert_equal false, HAMLProcessor.processes_file?("testhaml")

    # positive tests
    assert HAMLProcessor.processes_file?("test.haml")
    assert HAMLProcessor.processes_file?("test.HAML")

  end

  def test_name
    assert_equal "HAML", HAMLProcessor.processor_name
  end

  def test_generate
    assert_equal(
      "<strong class='code' id='message'>Hello, World!</strong>",

      HAMLProcessor.filter_string(:generate,
        %q{
          %strong{:class => "code", :id => "message"} Hello, World!
        }.align
      ).strip
    )
  end

  def test_minify
    assert_equal(
      "<quote><p><strong class=\"code\" id=\"message\">Hello, World!</strong></p></quote>",

      HAMLProcessor.filter_string([:generate, :minify],
        %q{
          %quote
            %p
              %strong{:class => "code", :id => "message"} Hello, World!
        }.align
      ).strip
    )
  end

end
