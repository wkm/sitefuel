#
# File::      test_CSSProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the CSSProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/CSSProcessor'
require 'sitefuel/extensions/StringFormatting'

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

  def test_filter_strip_comments
    assert_equal(
      "\nbody {\n  margin: 5em; \n//\n}\n",
      CSSProcessor.filter_string(
        :strip_comments,
        %q{
          // this is a line comment on its own
          body {
            margin: 5em; // at the end of a line
          /* and here
             is a multi-line comment... */
          }
        }.align
      )
    )
  end

  def test_filter_clean_whitespace
    assert_equal(
      "body {\n// here's a little line comment. We want to be sure\n// it isn't mashed with the margin stuff below.\nmargin: 5em;\n}\n",
      CSSProcessor.filter_string(
        :clean_whitespace,
        %q{
          body {
            // here's a little line comment. We want to be sure
            // it isn't mashed with the margin stuff below.
            margin: 5em;
          }
        }.align
      )
    )


    # finally, let's test the strip_comments and clean_whitespace filters
    # all together. (and incidentally test giving #filter_string an array)
    assert_equal(
      "body {\nmargin: 5em;\n}\n",
      CSSProcessor.filter_string(
        [:strip_comments, :clean_whitespace],
        %q{
          body {
            // here's a little line comment. We want to be sure
            // it isn't mashed with the margin stuff below.
            margin: 5em;
          }
        }.align
      )
    )
  end

  # note that minification is based on CSSMin, so it's not too heavily tested
  def test_minify
    # test: whitespace removal; hexcode compaction; comment stripping
    assert_equal(
      "body{color:#000;}",
      CSSProcessor.filter_string(
        :minify,
        <<-END
          body {
            /* comments should be stripped */
            color: #000000;
          }
        END
      )
    )

    assert_equal(
      "h1 .header{color:white;margin:0;font-family:\"lucida grande\",lucida,verdana,sans-serif;}a:hover{text-decoration:none;}",
      CSSProcessor.filter_string(
        :minify,
        <<-END
          h1 .header
          {
            color: white;
            margin: 0 0 0 0;
            font-family: "lucida grande", lucida, verdana, sans-serif;
          }

          a:hover {
            text-decoration: none;
          }
        END
      )
    )
  end
end
