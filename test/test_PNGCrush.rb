#
# File::        test_PNGCrush.m
# Author::      wkm
# Copyright::   2009
# License::     GPL
#
# Unit tests for the PNGCrush wrapper.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sitefuel/external/ExternalProgramTestCase'
require 'sitefuel/external/PNGCrush'

include SiteFuel::External

class TestPNGCrush < Test::Unit::TestCase
  include ExternalProgramTestCase

  SAMPLE_IMAGE = 'test/images/sample_png01.png'

  def test_option
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
    new_image = './test/images/tmp-sample_png01-brute.png'
    PNGCrush.brute SAMPLE_IMAGE, new_image

    assert File.size(SAMPLE_IMAGE) > File.size(new_image)

  end

  def test_quick
    new_image = './test/images/tmp-sample_png01-quick.png'
    PNGCrush.quick SAMPLE_IMAGE, new_image

    assert File.size(SAMPLE_IMAGE) > File.size(new_image)
  end

  def test_chainsaw
    new_image = './test/images/tmp-sample_png01-chainsaw.png'
    PNGCrush.chainsaw SAMPLE_IMAGE, new_image

    assert File.size(SAMPLE_IMAGE) > File.size(new_image)
  end

end
