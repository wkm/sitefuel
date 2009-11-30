#
# File::           test_PNGProcessor.rb
# Author::         wkm
# Copyright::      2009
# License::        GPL
#
# Unit tests for the PNGProcessor
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'processors/PNGProcessor'

include SiteFuel::Processor

class TestPNGProcessor < Test::Unit::TestCase
  def test_file_extensions
    assert_equal false, PNGProcessor.processes_file?("testpng")

    assert PNGProcessor.processes_file?("test.png")
    assert PNGProcessor.processes_file?("test.PNG")
  end
end