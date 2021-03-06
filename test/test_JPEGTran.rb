#
# File::      test_JPEGTran.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the JPEGTran wrapper.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'sitefuel/external/ExternalProgramTestCase'
require 'sitefuel/external/JPEGTran'

include SiteFuel::External

class TestJPEGTran < Test::Unit::TestCase
  include ExternalProgramTestCase

  SAMPLE_IMAGE = 'test/images/sample_jpg01.jpg'

  def test_options
    assert JPEGTran.option?(:version)
    assert JPEGTran.option?(:copy)
    assert JPEGTran.option?(:optimize)
    assert JPEGTran.option?(:perfect)
    assert JPEGTran.option?(:input)
    assert JPEGTran.option?(:output)

    assert_equal '-optimize', JPEGTran.option_template(:optimize)
  end

  def test_lossless
    new_image =  'test/images/tmp-sample_jpg01-lossless.jpg'
    JPEGTran.compress_losslessly SAMPLE_IMAGE, new_image


    assert File.size(SAMPLE_IMAGE) > File.size(new_image)
  end
end
