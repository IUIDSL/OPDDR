#!/bin/sh
#############################################################################
# NPC-PD2: produce results CSV file.
# Input from:
#  * OIDD 
#
# Jeremy Yang
# 2015 Feb 08
#############################################################################
#
if [ "`uname -s`" = "Darwin" ]; then
	APPDIR="/Users/app"
elif [ "`uname -s`" = "Linux" ]; then
	APPDIR="/home/app"
else
	APPDIR="/home/app"
fi
#
DATADIR="`dirname $0`/data"
#
set -e
#set -x
#
##################################
#File from OIDD/Jeff S., Natalie F.:
resultsfile_raw="${DATADIR}/NPC-OIDD-Results_raw.csv"
#
#Fix newline issues (due to Excel export):
perl -pi -e 's/\r\n*/\n/g;' $resultsfile_raw
#
resultsfile="${DATADIR}/NPC-OIDD-Results.csv"
printf "OUTPUT RESULTS FILE: %s\n" $resultsfile
#
coltags="OIDD_ASSAY NCGC_ID CONCENTRATION_uM RESULT_TYPE IC50_PREFIX ASSAY_RESULT ASSAY_RESULT_UOM ASSAY_OUTCOME RUN_DATE TEST_TYPE"
#
printf "Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i $resultsfile_raw --subsetcols --coltags "$coltags" --o $resultsfile
#
csv_utils.py --i $resultsfile --renamecol --coltag "CONCENTRATION_uM" --newtag "CONCENTRATION" --overwrite_input_file
csv_utils.py --i $resultsfile --renamecol --coltag "IC50_PREFIX" --newtag "RESULT_PREFIX" --overwrite_input_file
csv_utils.py --i $resultsfile --renamecol --coltag "ASSAY_RESULT" --newtag "RESULT" --overwrite_input_file
csv_utils.py --i $resultsfile --renamecol --coltag "ASSAY_RESULT_UOM" --newtag "RESULT_UOM" --overwrite_input_file
csv_utils.py --i $resultsfile --renamecol --coltag "ASSAY_OUTCOME" --newtag "OUTCOME" --overwrite_input_file
#
csv_utils.py --i $resultsfile --colcount_all
#
for tag in "OIDD_ASSAY" "OUTCOME" "RESULT_UOM" "RESULT_PREFIX"; do
	csv_utils.py --i $resultsfile --coltag "$tag" --colvalcounts
done
#
