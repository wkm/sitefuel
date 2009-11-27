#!/bin/bash

#
# File::      coverage.sh
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Bash script to test coverage of the unit test suite
#

rcov --sort coverage -i 'sitefuel/' -x '.*' --no-html -T test_*.rb