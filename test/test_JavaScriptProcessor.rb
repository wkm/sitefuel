#
# File::      test_JavaScriptProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the JavaScriptProcessor
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/processors/JavaScriptProcessor'

include SiteFuel::Processor

class TestJavaScriptProcessor < Test::Unit::TestCase

  def test_file_extensions
    assert JavaScriptProcessor.processes_file?('foo.js')
  end

  def test_name
    assert_equal 'JS', JavaScriptProcessor.processor_name
  end

  # CDATA fields need to be left intact
  def test_cdata
    assert_equal(
      "//<![CDATA[\nfunction foo(){12}\n//]]>",

      JavaScriptProcessor.filter_string(:minify,
        %q{
          //<![CDATA[
          function foo() {
            12
          }
          //]]>
        }
      )
    )
  end

  # test comment-only javascripts
  def test_comments_only
    assert_equal(
      '',
      JavaScriptProcessor.filter_string(:minify,
        %q{
          // just a comment....
        }
      )
    )

    assert_equal(
      '',
      JavaScriptProcessor.filter_string(:minify,
        %q{//just a comment...}
      )
    )
  end

end

