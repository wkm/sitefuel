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

    assert_equal '-brute',   PNGCrush.option_template(:brute)
#    assert_equal '-version', PNGCrush.option_template(:version)
  end

  def test_brute
    # test the crush capability against one of the test files
    PNGCrush.brute 'test_images/sample_png01.png',
                   'test_images/tmp-sample_png01-brute.png'

    PNGCrush.quick 'test_images/sample_png01.png',
                   'test_images/tmp-sample_png01-quick.png'
  end

end