#
# File::      test_Configurable.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the configurable-class abstraction
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/extensions/SymbolComparison'
require 'sitefuel/processors/Configurable'

include SiteFuel::Processor

class A
  include Configurable

  attr_accessor :size, :weight, :weight_unit
  attr_accessor :pre_configured, :post_configured

  def initialize
    @pre_configured = false
    @post_configured = false
  end

  def configure_size(size)
    @size = size
  end

  def configure_weight(weight, unit = :inches)
    @weight = weight
    @weight_unit = unit
  end

  def pre_configuration
    @pre_configured = true
  end

  def post_configuration
    @post_configured = true
  end
end

class TestConfigurable < Test::Unit::TestCase
  def test_options
    a = A.new

    assert_equal [:size, :weight], a.configuration_options.sort
  end

  def test_configuring
    a = A.new

    # test a config with no parameters
    a = A.new
    assert_nothing_raised { a.configure }

    # specifically: ensure the pre and post configuration were still
    # run
    assert a.pre_configured
    assert a.post_configured
        

    # test a normal config
    assert_nothing_raised { a.configure :size => 5 }
    assert a.pre_configured
    assert a.post_configured
    assert_equal 5, a.size

    
    # test a config with default value
    assert_nothing_raised { a.configure :weight => 3.14 }
    assert a.pre_configured
    assert a.post_configured
    assert_equal 3.14, a.weight
    assert_equal :inches, a.weight_unit


    # test two config options
    assert_nothing_raised do
      a.configure :size => 5,
                  :weight => 3.14
    end
    assert a.pre_configured
    assert a.post_configured
    assert_equal 5, a.size
    assert_equal 3.14, a.weight
    assert_equal :inches, a.weight_unit


    # test two config options with multiple parameters
        assert_nothing_raised do
      a.configure :size => 5,
                  :weight => [3.14, :meters]
    end
    assert a.pre_configured
    assert a.post_configured
    assert_equal 5, a.size
    assert_equal 3.14, a.weight
    assert_equal :meters, a.weight_unit

  end
end