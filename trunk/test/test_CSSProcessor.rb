# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'processors/CSSProcessor.rb'

include SiteFuel::Processor

class TestCSSProcessor < Test::Unit::TestCase
  def test_file_extensions
    css = CSSProcessor.new

    # negative tests
    assert_equal false, css.processes_file?("testcss")
    assert_equal false, css.processes_file?("test.css.foo")

    # positive tests
    assert css.processes_file?("test.css")
    assert css.processes_file?("test.CSS")
    assert css.processes_file?("test.CsS")
  end
end
