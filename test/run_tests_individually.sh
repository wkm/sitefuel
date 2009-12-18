#!/bin/bash
#
# File::      run_tests_individually.sh
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL
#
# Little bash script to run each test file indivudally. Ocasionally there are
# load path issues that running the tests all at once hides.
#

find . -name 'test_*.rb'  -exec echo \; -exec echo '-----------------------' \; -exec echo {} \; -exec ruby {} \;