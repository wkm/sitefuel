#!/bin/bash
#
# File::      nightly_test.sh
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Script which is run nightly at midnight UTC. This sends all developers
# a test report.
#

tmpfile="/tmp/sitefuel-nightlytestreport-"$RANDOM

echo 'Putting results in: '$tmpfile

echo 'Date: ' $(date -u)

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Unit tests' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile

./ts_all.rb >> $tmpfile

echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Coverage' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
./coverage.sh >> $tmpfile


echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Processors' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
./processor_listing.rb >> $tmpfile

echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Code Statistics' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
./loc.sh >> $tmpfile

echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Test Sanity Checks' >> $tmpfile
./run_tests_individually.sh >> $tmpfile

mail -s '[sitefuel] Nightly Test Report' wmacura@gmail.com < $tmpfile