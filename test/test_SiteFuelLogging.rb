#
# File::       test_SiteFuelLogging.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the sitefuel logging class
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'Logger'
require 'SiteFuelLogger'

include SiteFuel

class TestSiteFuelLogging < Test::Unit::TestCase
  def test_fatal
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    assert_equal 0, log.fatal_count
    log.fatal('fatal error')
    assert_equal 1, log.fatal_count
    log.fatal('apparently not so fatal, since here\'s another fatal error')
    assert_equal 2, log.fatal_count
  end

  def test_errors
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    assert_equal 0, log.error_count
    log.error('just an error')
    assert_equal 1, log.error_count
    log.error('another error')
    assert_equal 2, log.error_count
  end

  def test_warnings
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    assert_equal 0, log.warning_count
    log.warn('just a warning')
    assert_equal 1, log.warning_count
    log.warn('another warning :)')
    assert_equal 2, log.warning_count
  end

  def test_info_messages
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    assert_equal 0, log.info_count
    log.info('oh hello, just letting you know...')
    assert_equal 1, log.info_count
    log.info('... the sky is still blue.')
    assert_equal 2, log.info_count
  end

  def test_debug_messages
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    assert_equal 0, log.debug_count
    log.debug('about to run an assert!')
    assert_equal 1, log.debug_count
    log.debug('wadda ya know. about to run another assert.')
    assert_equal 2, log.debug_count
  end
end