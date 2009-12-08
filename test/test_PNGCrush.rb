#
# File::        test_PNGCrush.m
# Author::      wkm
# Copyright::   2009
# License::     GPL
#
# Unit tests for the PNGCrush wrapper.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'sitefuel/external/PNGCrush'

include SiteFuel::External

class TestPNGCrush < Test::Unit::TestCase

  def test_options
    # test that we have all options
    assert PNGCrush.option?(:version)
    assert PNGCrush.option?(:brute)
    assert PNGCrush.option?(:reduce)
    assert PNGCrush.option?(:method)
    assert PNGCrush.option?(:input)
    assert PNGCrush.option?(:output)
  end

  def test_crush
    # test the crush capability against one of the test files
  end

end