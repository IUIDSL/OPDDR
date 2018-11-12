#!/bin/sh
#############################################################################
# NPC-PD2: produce assays CSV file.
# Input from:
#  * OIDD 
#
# Jeremy Yang
#  3 Feb 2015
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
assayfile_raw="${DATADIR}/NPC-OIDD-Assay_raw.csv"
#
#Fix newline issues (due to Excel export):
perl -pi -e 's/\r\n*/\n/g;' $assayfile_raw
#
assayfile="${DATADIR}/NPC-OIDD-Assay.csv"
printf "OUTPUT ASSAY FILE: %s\n" $assayfile
#
coltags="OIDD_ASSAY ASSAY_NAME METHOD ASSAY_TECHNOLOGY ASSAY_PROJECT ASSAY_SUB-PROJECT CELL_LINE CELL_LINE_DESCRIPTION ASSAY_ROLE RESULT_TYPE DESIRED_RESULT SCREENING_THRESHOLD_UM"
#
printf "Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i $assayfile_raw --subsetcols --coltags "$coltags" --o $assayfile
#
csv_utils.py --i $assayfile --renamecol --coltag "OIDD_ASSAY" --newtag "OIDD_ID" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "ASSAY_NAME" --newtag "NAME" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "ASSAY_TECHNOLOGY" --newtag "TECHNOLOGY" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "ASSAY_PROJECT" --newtag "PROJECT" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "ASSAY_SUB-PROJECT" --newtag "SUBPROJECT" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "ASSAY_ROLE" --newtag "ROLE" --overwrite_input_file
csv_utils.py --i $assayfile --renamecol --coltag "SCREENING_THRESHOLD_UM" --newtag "SCREENING_THRESHOLD" --overwrite_input_file
#
csv_utils.py --i $assayfile --colcount_all
#
for tag in "OIDD_ID" "NAME" "PROJECT" "SUBPROJECT" "ROLE" "METHOD" "TECHNOLOGY" ; do
 	csv_utils.py --i $assayfile --coltag "$tag" --colvalcounts
done
#
