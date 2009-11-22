#!/usr/bin/ruby

require 'test/unit' 

# programmatically load all test files in this directory
testfiles = Dir["test_*.rb"];

puts '='*60
puts 'Loaded:'
puts testfiles.join("\n")
puts '='*60

testfiles.each do |testfile|
  require testfile
end

