#!/bin/bash

#
# File::      coverage.sh
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Bash script to test coverage of the unit test suite
#

rcov --comments --only-uncovered --sort coverage -i 'sitefuel/' -x '.*' --no-html -T ../test/test_*.rb