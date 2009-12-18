#!/bin/bash

#
# File::      loc.sh
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Simple utility for counting the number of lines of code
#

echo '  # of ruby files            :' $(find .. -name '*.rb' | wc -l)
echo '------------------------------------------------'
echo '  everything                 :' $(cat $(find .. -name '*.rb') | wc -l)
echo '  w/o whitespace             :' $(cat $(find .. -name '*.rb') | grep -v -e "^[ \t\n]*$" | wc -l)
echo '  w/o whitespace and comments:' $(cat $(find .. -name '*.rb') | grep -v -e "^[ \t\n]*$" -e "^[ \t\n]*#.*$" | wc -l)
echo '  w/o test-files:            :' $(cat $(find .. -name '*.rb' | grep -v 'test/') | grep -v -e "^[ \t\n]*$" -e "^[ \t\n]*#.*$" | wc -l)