#!/usr/bin/ruby -w
#
# File::      ts_all.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# The entirety test suite. Runs all tests.
#

require 'test/unit' 

# programmatically load all test files in this directory
testfiles = Dir[File.join(File.dirname(__FILE__), "test_*.rb")];

puts '='*60
puts 'Loaded:'
puts testfiles.join("\n")
puts '='*60

testfiles.each do |testfile|
  require testfile
end

