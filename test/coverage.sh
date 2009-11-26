#!/bin/bash

#
# File::      coverage.sh
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Bash script to test coverage of the unit test suite
#

set thresh='--threshold 100'
rcov --xrefs --sort coverage -i 'sitefuel/' -x '.*' $thresh --no-html -T test_*.rb