#!/bin/sh
#
#
rawcsv=data/GLP_1_Secretion.csv
#
set -x
#
perl -pi -e 's/\r\n*/\n/g;' $rawcsv
#
