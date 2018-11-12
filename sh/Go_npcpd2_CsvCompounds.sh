#!/bin/sh
#############################################################################
# NPC-PD2: produce compounds CSV file.
# Input from:
#  * OIDD (CSV file: OIDD IDs and NCGC IDs)
#	Necessary to link into assay/activity data.
#  * NCATS (CSV file: PubChem SIDs)
#	Necessary for external IDs (PubChem).
#  * PubChem (REST API: CIDs, Smiles)
#	Valuable (not necessary) for CIDs, further linking, structural
#	verification, more IDs and synonyms.
#
# Provenance important.  Source of each field retained.  
# Initially, for redundant fields, select one source.  Ideally we would
# cross-check.  In this first version, focus on accurate mapping of IDs,
# specifically (1) NCATS/NCGC IDs, and (2) PubChem SIDs.  For other data
# rely on respective authoritative and accessible sources (e.g. PubChem
# for structures).
# 
# Jeremy Yang
#  8 Feb 2015
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
#File from OIDD/Jeff Sutherland:
#Prefix tags for provenance.
rawcsv_oidd="${DATADIR}/ncats_substances_no_LSN.txt"
csv_oidd_1="${DATADIR}/OIDD_01.csv"
#
csv_utils.py --i $rawcsv_oidd --tsv2csv --o $csv_oidd_1
#
csv_utils.py --i $csv_oidd_1 --size
csv_utils.py --i $csv_oidd_1 --colcount_all
#
csv_utils.py --i $csv_oidd_1 --renamecol --coltag "NAME" --newtag "NCGC_ID" --overwrite_input_file
#
csv_utils.py --i $csv_oidd_1 --coltag "NCGC_ID" --extractcol \
	|sort -u >${csv_oidd_1}.ncgcid_unique
#
echo 'OIDD file: Prefix tags...'
csv_utils.py --i $csv_oidd_1 --prefixtags --tagprefix "OIDD:" --overwrite_input_file
#
#Remove GSM_SUBMISSION_ID, a finer grained ID.
coltags="OIDD:OIDD_ID OIDD:NCGC_ID"
printf "OIDD file: Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i $csv_oidd_1 --subsetcols --coltags "$coltags" --overwrite_input_file
csv_utils.py --i $csv_oidd_1 --deduprows --coltag "OIDD:NCGC_ID" --overwrite_input_file
#
##################################
#File from NCATS:
#Prefix tags for provenance.
rawcsv_ncats="${DATADIR}/Lilly_NPC_Shipped_Compounds_141220.csv"
csv_ncats_1="${DATADIR}/NCATS_01.csv"
#
csv_utils.py --i $rawcsv_ncats --size
csv_utils.py --i $rawcsv_ncats --colcount_all
echo 'NCATS file: Fix tags...'
csv_utils.py --i $rawcsv_ncats --fixtags --o $csv_ncats_1
#
echo 'NCATS file: Prefix tags...'
csv_utils.py --i $csv_ncats_1 --prefixtags --tagprefix "NCATS:" --overwrite_input_file
#
coltags="NCATS:Sample_ID NCATS:PubChem_SID NCATS:Synonym"
printf "NCATS file: Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i $csv_ncats_1 --subsetcols --coltags "$coltags" --overwrite_input_file
#
##################################
#Merge on NCGC_ID.
mergefile="${DATADIR}/NPC-PD2_cpds_merged.csv"
#
printf "MERGED FILE: %s\n" ${mergefile}
#
echo 'Merging on "OIDD:NCGC_ID" and "NCATS:Sample_ID"...'
csv_utils.py \
	--merge \
	--coltag "OIDD:NCGC_ID" \
	--coltagB "NCATS:Sample_ID" \
	--i ${csv_oidd_1} \
	--iB ${csv_ncats_1} \
	--o ${mergefile}
#
csv_utils.py --i ${mergefile} --size
csv_utils.py --i ${mergefile} --colcount_all
#
##################################
#Merge NEW SIDs.
new_sids_file_raw="${DATADIR}/subm-36067-sids.csv"
new_sids_file="${DATADIR}/subm-36067-sids_clean.csv"
#
coltags="REGID SID CID"
printf "NEW_SIDS: Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i ${new_sids_file_raw} --subsetcols --coltags "$coltags" --o ${new_sids_file}
#
echo 'NEW_SIDS:Prefix tags...'
csv_utils.py --i ${new_sids_file} --prefixtags --tagprefix "NEW_SIDS:" --overwrite_input_file
#
echo 'Merging on "NCATS:NCGC_ID" and "NEW_SIDS:REGID"...'
#
set -x
#
csv_utils.py \
	--merge \
	--coltag "OIDD:NCGC_ID" \
	--coltagB "NEW_SIDS:REGID" \
	--i ${mergefile} \
	--iB ${new_sids_file} \
	--overwrite_input_file
#
csv_utils.py \
	--mergecols \
	--coltags "NCATS:PubChem_SID NEW_SIDS:SID" \
	--i ${mergefile} \
	--overwrite_input_file
#
#
##################################
sidfile="${mergefile}.sid"
csv_utils.py \
	--extractcol \
	--i ${mergefile} \
	--coltag "NCATS:PubChem_SID" \
	|grep -v '^ *$' \
	|sort -n \
	>$sidfile
#
printf "SID count: %d\n" `cat $sidfile |wc -l`
#
#Get PubChem annotations:
#May take several minutes:
sdffile="${sidfile}_pc.sdf"
#if [ -e "$sdffile" ]; then
#	printf "PubChem SDF file exists, not overwritten: %s\n" $sdffile
#else
	time pug_ids2mols.py \
		--idtype SID \
		--fmt sdf \
		--i $sidfile \
		--o $sdffile \
		--vv
#fi
#
# PUBCHEM_EXT_DATASOURCE_NAME should be 824, code for NCGC/NCATS.
# PUBCHEM_COMPOUND_ID_TYPE should all be 0, code for ???
# SDF Title is SID, redundant.
# Ignoring many PubChem fields which may be useful later.
#
inc_fields='PUBCHEM_SUBSTANCE_ID,PUBCHEM_CID_ASSOCIATIONS'
sdf2csv.py \
	--i $sdffile \
	--o ${sdffile}.csv \
	--uniform --truncate --smiles_first --ignore_title \
	--include --fields "$inc_fields"
#
#Merge on PubChem SID
echo 'Merging on "NCATS:PubChem_SID" and "PUBCHEM_SUBSTANCE_ID"...'
csv_utils.py \
	--merge \
	--coltag "NCATS:PubChem_SID" \
	--coltagB "PUBCHEM_SUBSTANCE_ID" \
	--i ${mergefile} \
	--iB ${sdffile}.csv \
	--overwrite_input_file
#
csv_utils.py --i ${mergefile} --size
csv_utils.py --i ${mergefile} --colcount_all
#
###
#Write final compound file:
###
cpdfile="${DATADIR}/NPC-OIDD-Compound.csv"
#
coltags="OIDD:OIDD_ID OIDD:NCGC_ID NCATS:PubChem_SID NCATS:Synonym SMILES PUBCHEM_CID_ASSOCIATIONS"
printf "Distribution file: Keep only selected columns: %s ...\n" "$coltags"
csv_utils.py --i $mergefile --subsetcols --coltags "$coltags" --o $cpdfile
#
csv_utils.py --i $cpdfile --renamecol --coltag "OIDD:OIDD_ID" --newtag "OIDD_ID" --overwrite_input_file
csv_utils.py --i $cpdfile --renamecol --coltag "OIDD:NCGC_ID" --newtag "NCGC_ID" --overwrite_input_file
csv_utils.py --i $cpdfile --renamecol --coltag "NCATS:PubChem_SID" --newtag "PUBCHEM_SID" --overwrite_input_file
csv_utils.py --i $cpdfile --renamecol --coltag "NCATS:Synonym" --newtag "TRIVIAL_NAME" --overwrite_input_file
csv_utils.py --i $cpdfile --renamecol --coltag "PUBCHEM_CID_ASSOCIATIONS" --newtag "PUBCHEM_CID" --overwrite_input_file
#
csv_utils.py --i $cpdfile --cleancol --coltag "PUBCHEM_CID" --overwrite_input_file
#
#Select only rows with cpd in results file.
resultsfile="${DATADIR}/NPC-OIDD-Results.csv"
csv_utils.py \
	--i $resultsfile \
	--coltag "NCGC_ID" \
	--extractcol \
	| sort -u \
	>${resultsfile}.ncgcid_unique
#
csv_utils.py --i $cpdfile --coltag "NCGC_ID" --selectrows \
	--valfile ${resultsfile}.ncgcid_unique \
	--overwrite_input_file
#
csv_utils.py --i $cpdfile --coltag "NCGC_ID" --extractcol \
	|sort -u >${cpdfile}.ncgcid_unique
#
csv_utils.py --i $cpdfile --coltag "OIDD_ID" --extractcol \
	|sort -nu |grep -v '^$' >${cpdfile}.oiddid_unique
#
csv_utils.py --i ${cpdfile} --size
csv_utils.py --i ${cpdfile} --colcount_all
#
printf "OUTPUT COMPOUND FILE: %s\n" ${cpdfile}
