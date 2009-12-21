#
# File::      test_SiteFuelLogging.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the sitefuel logging class
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'logger'

require 'sitefuel/SiteFuelLogger'

include SiteFuel

class TestSiteFuelLogging < Test::Unit::TestCase
  def test_fatal
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    fatal = log.fatal_count
    assert_equal fatal, log.fatal_count
    log.fatal('fatal error')
    assert_equal fatal+1, log.fatal_count
    log.fatal('apparently not so fatal, since here\'s another fatal error')
    assert_equal fatal+2, log.fatal_count
  end

  def test_errors
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    error = log.error_count
    assert_equal error, log.error_count
    log.error('just an error')
    assert_equal error+1, log.error_count
    log.error('another error')
    assert_equal error+2, log.error_count
  end

  def test_warnings
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    warn = log.warn_count
    assert_equal warn, log.warn_count
    log.warn('just a warning')
    assert_equal warn+1, log.warn_count
    log.warn('another warning :)')
    assert_equal warn+2, log.warn_count
  end

  def test_info_messages
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    info = log.info_count
    assert_equal info, log.info_count
    log.info('oh hello, just letting you know...')
    assert_equal info+1, log.info_count
    log.info('... the sky is still blue.')
    assert_equal info+2, log.info_count
  end

  def test_debug_messages
    log = SiteFuelLogger.instance
    log.level = Logger::UNKNOWN

    debug = log.debug_count
    assert_equal debug, log.debug_count
    log.debug('about to run an assert!')
    assert_equal debug+1, log.debug_count
    log.debug('wadda ya know. about to run another assert.')
    assert_equal debug+2, log.debug_count
  end
end