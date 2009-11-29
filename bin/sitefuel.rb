#!/usr/bin/ruby -w -rubygems

# == Synopsis
#
# A lightweight ruby framework for processing and deploying websites, either
# from
#
# === Introduction
# sitefuel is a lightweight ruby framework for deploying websites directly from
# version control. sitefuel includes support for compressing HTML and CSS as
# well as optimizing PNG graphics. Support is planned for SASS; compressing
# JavaScript; automatically creating sprites; and supporting more image formats.
# (and more!)
# TODO: add more details
#
# === Examples
# Process an already deployed site:
# <pre>sitefuel process /var/www/</pre>
#
# Deploy a site from SVN:
# <pre>sitefuel deploy svn+ssh://sitefuel.org/svn/tags/21 /var/www/</pre>
#
# Specify a non-default deployment file:
# <pre>sitefuel process /var/www/ -c customdeployment.yml</pre>
#
#
# == Author
# wkm, Zanoccio, LLC.
#
# == Copyright
# Copyright (c) 2009 Zanoccio.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

# add source/ to the load path
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rubygems'
require 'term/ansicolor'

require 'SiteFuelRuntime'

include Term::ANSIColor

def puts_and_exit(*args)
  puts(*args)
  exit
end

$HELP_HINT_LINE = "type \'#{$0} help\' for usage"

# parse command line arguments and configure a SiteFuelRuntime
def parse_command_line(runtime)

  #### BUILD THE OPTIONS PARSER
  opts = OptionParser.new
  opts.banner =  bold("SiteFuel #{$SiteFuelVersionText}\n")
  opts.banner << 'A ruby framework for deploying sites from version control.'
  opts.separator ''
  opts.separator bold('Usage: sitefuel  COMMAND  ARGUMENTS  [OPTIONS]')
  opts.separator ''
  opts.separator bold('Commands:')
  opts.separator "    deploy\tDeploy a site using sitefuel."
  opts.separator "    process\tModify an existing deployment in-place."
  opts.separator "    help\tShow this message."
  opts.separator ''
  opts.separator bold('Common options:')
  opts.on('-oARG', '-o=ARG', '-o PLACE', '--output=ARG', '--output PLACE', String,
          'Where to put a deployed site') do |out|
    runtime.deploy_from = out
  end
  opts.on('-v', '--version', 'Gives the version of sitefuel') {|| puts 'sitefuel ' + $SiteFuelVersion.join('.')}
  opts.on('--[no-]verbose', 'Cause sitefuel to be verbose, listing actions as they are preformed') {|| puts 'cause sitefuel to be verbose listing actions as they are preformed' }
  opts.on('-h', '--help', '-?', '--about', 'Gives help for a specific command.') do
    puts opts
    exit
  end

  opts.separator ''
  opts.separator 'Specific options for a command can be seen with: '
  opts.separator '    COMMAND --help'


  opts.separator ''
  opts.separator 'More information: http://sitefuel.org'
  opts.separator 'Getting started: http://sitefuel.org/getstarted'
  opts.separator 'Documentation: http://sitefuel.org/documentation'


  #### ATTEMPT TO PARSE THE COMMAND LINE
  begin
    commands = opts.parse(*ARGV)
  rescue OptionParser::InvalidOption => iopt
    puts iopt
    puts_and_exit $HELP_HINT_LINE
  rescue => exception
    # TODO: add better handling for the various exceptions (unncessary
    #       argument, missing argument, etc.)
    puts_and_exit "couldn\'t parse command line: #{exception}", $HELP_HINT_LINE
  end


  # note that --help will have already been intercepted but 'help' still needs
  # special treatment
  puts_and_exit 'no command given', $HELP_HINT_LINE if commands.length < 1
  puts_and_exit opts if commands[0].downcase == 'help'

  case commands[0].downcase
  when 'deploy':
    runtime.deploy_from = commands[1]
    runtime.deploy
  else
    puts_and_exit "unknown command: '#{commands[0]}'", $HELP_HINT_LINE
  end
end

def main
  runtime = SiteFuel::SiteFuelRuntime.new
  parse_command_line(runtime)
end

main()
