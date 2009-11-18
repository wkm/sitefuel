#
# File::      SiteFuelLogger.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  require 'Logger'

  # Abstraction around the Logger:: library, typically every processor
  # will hook into using this logger while letting us control it's placement
  # and display globally
  class SiteFuelLogger
    attr_reader :log

    def initialize(filename, archive_size)
      @log = Logger.new(filename)
    end

    def level=
    end

    # TODO: should we just inherit Logger?
    def error(*args) @log.error(*args); end
    def warn(*args) @log.warn(*args); end
    def info(*args) @log.info(*args); end
    def debug(*args) @log.debug(*args); end
  end
end