#!/usr/bin/ruby -wrubygems

#
# File::      ts_all.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# The entirety test suite. Runs all tests.
#

require 'test/unit'
require 'term/ansicolor'
include Term::ANSIColor

$Divider = '='*60

# programmatically load all test files in this directory
testfiles = Dir[File.join(File.dirname(__FILE__), "test_*.rb")];

  # some whitespace

puts $Divider
puts bold('Found: %d test files' % testfiles.length)
puts testfiles.join("\n")

puts $Divider
puts bold('Loading:')

testfiles.each do |testfile|
  load testfile
  putc '.'
  STDOUT.flush
end
puts

puts $Divider
puts bold('Results:')

