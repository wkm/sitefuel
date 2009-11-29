#
# File::      SiteFuelLogger.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  
  require 'Logger'
  require 'singleton'

  # Singleton abstraction around the Logger:: library, typically every processor
  # will hook into using this logger while letting us control it's placement
  # and display globally
  class SiteFuelLogger < Logger
    include Singleton

    # the number of fatal messages logged so far (even if lower than #level)
    attr_reader :fatal_count

    # the number of error messages logged so far (even if lower than #level)
    attr_reader :error_count

    # the number of warning messages logged so far (even if lower than #level)
    attr_reader :warn_count

    # the number of info messages logged so far (even if lower than #level)
    attr_reader :info_count

    # the number of debug messages logged so far (even if lower than #level)
    attr_reader :debug_count

    def initialize(filename = STDOUT)
      @fatal_count = 0
      @error_count = 0
      @warn_count = 0
      @info_count = 0
      @debug_count = 0
      
      super(filename)
    end

    def fatal(*args)
      @fatal_count += 1
      super(*args)
    end

    def error(*args)
      @error_count += 1
      super(*args)
    end

    def warn(*args)
      @warn_count += 1
      super(*args)
    end

    def info(*args)
      @info_count += 1
      super(*args)
    end

    def debug(*args)
      @debug_count += 1
      super(*args)
    end
  end

  # mixin for adding logging functionality to any class, typically included
  # by every SiteFuel class
  module Logging
    # sets the logger for a class
    def logger=(logger)
      @logger = logger
    end

    # adds a fatal error to the log
    def fatal(*args) @logger.fatal(*args); end
    
    # adds an error to the log
    def error(*args) @logger.error(*args); end

    # adds a warning to the log
    def warn(*args) @logger.warn(*args); end

    # adds an info message to the log
    def info(*args) @logger.info(*args); end

    # adds a debugging message to the log
    def debug(*args) @logger.debug(*args); end
  end
end