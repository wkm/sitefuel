#!/bin/bash
#
# File::      load_files_individually.sh
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Little bash script to load each file individually; this ensures the require
# statements are correct.
#

find ../lib -name '*.rb'  -exec echo \; -exec echo '-----------------------' \; -exec echo {} \; -exec ruby -C../lib {} \;