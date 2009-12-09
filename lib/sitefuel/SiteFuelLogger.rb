#
# File::      SiteFuelLogger.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  
  require 'logger'
  require 'singleton'
  require 'term/ansicolor'

  include Term::ANSIColor

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

    # adjust the style of logging:
    #
    # default:: use the Logger logging style
    # clean:: gives a clean logging output intended for human use
    attr_accessor :log_style

    def initialize(filename = STDOUT)
      super(filename)
      
      @fatal_count = 0
      @error_count = 0
      @warn_count = 0
      @info_count = 0
      @debug_count = 0

      self.level = WARN
      @log_style = :default
      @progname = 'SiteFuel'
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

    # implement our own #add so we can have cleaner logs
    def format_message(severity, date_time, program_name, msg)
      case @log_style
        when :default
          super(severity, date_time, program_name, msg)

        when :clean
          string = "#{severity}: #{msg}\n"
          case severity
            when 'ERROR', 'FATAL'
              string = bold(red(string))

            when 'WARN'
              string = yellow(string)

            when 'DEBUG'
              string = string
          end
          string
      end
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