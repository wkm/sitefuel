#!/usr/bin/ruby -w -rubygems

#
# File::      ts_all.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
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
  require testfile
end

puts $Divider
puts bold('Results:')
