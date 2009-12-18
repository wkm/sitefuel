#!/usr/bin/ruby
#
# File::      versioning.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Simple program for testing various versioning controls
#


if not $*.empty?
  case $*[0]
    when '--version'
    puts '0.1.2'

    when '--version-2'
    puts '0.1.2asdad'

    when '--version-3'
    puts '0.2'

    when '--version-4'
    puts 'test-program v.0.1.2'
  end
end 