#
# File::      test_PNGProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the PNGProcessor
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/processors/PNGProcessor'

include SiteFuel::Processor

class TestPNGProcessor < Test::Unit::TestCase
  def test_file_extensions
    assert_equal false, PNGProcessor.processes_file?("testpng")

    assert PNGProcessor.processes_file?("test.png")
    assert PNGProcessor.processes_file?("test.PNG")
  end

  def test_name
    assert_equal 'PNG', PNGProcessor.processor_name
  end

  def test_crush
    PNGProcessor.process_file('test/images/sample_png01.png')
  end
end