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

echo 'DATE: ' $(date -u) >> $tmpfile
echo 'DIFF:' >> $tmpfile

git diff --stat master master@{1} >> $tmpfile


echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'Unit tests' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile

ruby -w ./ts_all.rb >> $tmpfile

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
ruby -w ./processor_listing.rb >> $tmpfile

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
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
./run_tests_individually.sh >> $tmpfile


echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
echo 'File require checks' >> $tmpfile
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' >> $tmpfile
./load_files_individually.sh >> $tmpfile

mail -s 'SiteFuel Nightly Test Report' testing@sitefuel.org < $tmpfile