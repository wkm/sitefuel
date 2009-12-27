#
# File::      CommandLine.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Contains the command line parser for the sitefuel program
#


module SiteFuel
  module CommandLine

    require 'rdoc/usage'
    require 'term/ansicolor'

    require 'sitefuel/License'

    include Term::ANSIColor

    def self.puts_and_exit(*args)
      puts(*args)
      exit
    end
  
    $HELP_HINT_LINE = "type '#{$0} help' for usage"

    @option_parser = nil

    # parse command line arguments and configure a SiteFuelRuntime
    def self.parse_command_line(runtime)

      #### BUILD THE OPTIONS PARSER
      @option_parser = OptionParser.new

      # the banner text comes from the header comment for this file

      @option_parser.on('-o PLACE', '--output=ARG', '--output PLACE', String,
              'Where to put a deployed site') do |out|
        runtime.deploy_to = out
      end
      @option_parser.on('-v', '--version', 'Gives the version of sitefuel') do
        puts_and_exit 'SiteFuel ' + VERSION_TEXT
      end

      #
      # Verbosity options
      #

      @option_parser.on('--[no-]verbose', 'List actions as they are preformed') do |be_verbose|
        if be_verbose
          # fatal, error, warnings, and info
          runtime.verbosity(3)
        else
          # fatal, error, and warnings
          runtime.verbosity(2)
        end
      end

      @option_parser.on('--debug', 'Gives verbose debugging information') do
        runtime.verbosity(4)
      end

      @option_parser.on('--abort-errors', '[default] Abort deployment if there are errors') do
        runtime.abort_on_errors = true
      end

      @option_parser.on('--ignore-errors', 'Deploy even if there are errors') do
        runtime.abort_on_errors = false
        runtime.abort_on_warnings = false
      end

      @option_parser.on('--abort-warnings', 'Abort deployment if there are warnings') do
        runtime.abort_on_warnings = true
        runtime.abort_on_errors = true
      end

      @option_parser.on('--ignore-warnings', '[default] Deploy even if there are warnings') do
        runtime.abort_on_warnings = true
      end

      @option_parser.on('--only-list-recognized-files', 'Only list summaries for files which were changed') do
        runtime.only_list_recognized_files = true
      end

      @option_parser.on('-h', '--help', '-?', '--about', 'Gives help for a specific command.') do
        RDoc::usage_no_exit('Synopsis', 'Usage', 'Introduction')
        puts @option_parser
        RDoc::usage_no_exit('Examples', 'Author', 'Copyright')
        exit
      end

      @option_parser.on('--license', 'Gives the license for SiteFuel.') do
        puts_and_exit SiteFuel::LICENSE
      end

      @option_parser.separator ''
      @option_parser.separator 'Specific options for a command can be seen with: '
      @option_parser.separator '    COMMAND --help'


      #### ATTEMPT TO PARSE THE COMMAND LINE
      begin
        commands = @option_parser.parse(*ARGV)
      rescue OptionParser::InvalidOption => invalid_option
        puts invalid_option
        puts_and_exit $HELP_HINT_LINE
      rescue => exception
        # TODO: add better handling for the various exceptions (unnecessary
        #       argument, missing argument, etc.)
        puts_and_exit "couldn't parse command line: #{exception}", $HELP_HINT_LINE
      end


      # note that --help will have already been intercepted but 'help' still needs
      # special treatment
      puts_and_exit 'no command given', $HELP_HINT_LINE if commands.length < 1
      puts_and_exit @option_parser if commands[0].downcase == 'help'

      case commands[0].downcase
        when 'deploy'
          runtime.deploy_from = commands[1]
          runtime.deploy_to   = commands[2]
          runtime.deploy

        when 'stage'
          runtime.deploy_from = commands[1]
          runtime.stage

        else
          puts_and_exit "unknown command: '#{commands[0]}'", $HELP_HINT_LINE
      end
    end
  end
end