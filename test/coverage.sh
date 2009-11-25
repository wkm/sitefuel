#!/bin/bash
#
#
#  -f lib/*.rb

set thresh='--threshold 100'
rcov --xrefs --sort coverage -i 'sitefuel/' -x '.*' $thresh --no-html -T test_*.rb