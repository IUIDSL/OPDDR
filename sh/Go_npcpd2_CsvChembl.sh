#!/bin/sh
#############################################################################
# NPC-PD2: produce ChEMBL CSV files.
# 
# Get ChEMBL bioactivity data for compounds.
# Inchi files obsoleted by UniChem mappings (PubChem CID to Chembl ID).
# 
# Files produced:
#  (1) ChEMBL compounds: CHEMBL_ID, activity data.
#  (2) ChEMBL targets: CHEMBL_ID, names, etc.
#############################################################################
# Where is pChEMBL score? Via REST? https://www.ebi.ac.uk/chembl/faq#faq41
#############################################################################
# Jeremy Yang
#  1 May 2016
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
#set -e
#set -x
#
##################################
#Compound file, from Go_npcpd2_Compound.sh::
###
cpdfile="${DATADIR}/NPC-OIDD-Compound.csv"
###
#Extract CIDs:
#
csv_utils.py --i $cpdfile --coltag "PUBCHEM_CID" --extractcol \
	|grep -v '^$' \
	>${cpdfile}.cid
###
#From Unichem, get ChEMBL_ID:
# Note that unichem_src1src22.txt.gz is comprehensive.
###
#Why only 2292 / 2506 mapped?
#(Could be correct, if no previous activity for these compounds, or none qualified for import to Chembl.)
###
echo "chembl_mol_id,pubchem_cid" >data/unichem_chembl2pccid.csv
#
gunzip -c data/unichem_src1src22.txt.gz \
	|sed -e '1d' \
	|awk '{print $1 "," $2}' \
	>>data/unichem_chembl2pccid.csv
#
#
cid2chemblidfile="${DATADIR}/cid2chemblid.csv"
printf "cid,chemblid\n" >$cid2chemblidfile
#
Ncid=`cat ${cpdfile}.cid |wc -l`
printf "Ncid = %d\n" $Ncid
i=0
i_found=0
while [ $i -lt $Ncid ]; do
	i=`expr $i + 1`
	cid=`cat ${cpdfile}.cid |sed "${i}q;d"`
	chemblid=`cat data/unichem_chembl2pccid.csv |grep ",${cid}\$" |head -1 |sed -e 's/,.*$//'`
	if [ ! "$chemblid" ]; then
		printf "%d. ERROR: CID=%s CHEMBLID NOT FOUND.\n" $i $cid
	else
		printf "%d. CID=%s CHEMBLID=%s\n" $i $cid $chemblid
		i_found=`expr $i_found + 1`
		printf "%s,%s\n" $cid $chemblid >>$cid2chemblidfile
	fi
done
printf "%d / %d CHEMBLIDs found.\n" $i_found $i
#
csv_utils.py \
	--i $cid2chemblidfile \
	--coltag "chemblid" \
	--extractcol \
	>${cid2chemblidfile}.chemblid
###
#From ChEMBL, via ChEMBL_ID, get bioactivity summary data including protein targets:
#Slow!
#
chembl_activity_file="${DATADIR}/chembl_activity.csv"
printf "(1) CHEMBL FILE (activity): %s\n" "${chembl_activity_file}"
if [ ! -e ${chembl_activity_file} ]; then
	chembl_query.py \
		--get_activity_mol \
		--idfile ${cid2chemblidfile}.chemblid \
		--o ${chembl_activity_file}
else
	printf "File exists, not overwritten: %s\n" ${chembl_activity_file}
fi
#
#
csv_utils.py --i ${chembl_activity_file} --coltag "assay_type" --colvalcounts
#csv_utils.py --i ${chembl_activity_file} --coltag "bioactivity_type" --colvalcounts
#csv_utils.py --i ${chembl_activity_file} --coltag "target_confidence" --colvalcounts
###
#
##
chembl_target_file="${DATADIR}/chembl_target.csv"
printf "(2) CHEMBL file (target): %s\n" $chembl_target_file
#
csv_utils.py \
	--i ${chembl_activity_file} \
	--extractcol \
	--coltag "target_chemblid" \
	| sort -u \
	|grep '^CHEMBL' \
	>data/chembl_target.id
#
# Produce file containing "targetType", to select "SINGLE PROTEIN" only.
#
chembl_query.py \
	--get_tgt \
	--idfile data/chembl_target.id \
	--o ${chembl_target_file}
#
