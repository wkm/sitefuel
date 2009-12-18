#!/bin/bash

#
# File::      coverage_annotation.sh
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL
#
# Bash script to test coverage of the unit test suite and generate annotated
# HTML for the source code which isn't completely covered.
#

rcov --comments --only-uncovered --sort coverage -i 'sitefuel/' -x '.*' -T test_*.rb

