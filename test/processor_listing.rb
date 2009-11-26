#!/usr/bin/ruby
#
# File::      processor_listing.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Lists all the processors in SiteFuel with their file patterns
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'SiteFuelRuntime'
include SiteFuel

SiteFuelRuntime.load_processors
processors = SiteFuelRuntime.find_processors
processors = processors.delete_if do |proc| 
  proc.processor_name =~ /Abstract.*/ 
end
processors.each do |proc|
  puts ' | %s | %s |'% [proc.processor_name.ljust(10), proc.file_patterns.join(', ').ljust(30)]
end