#!/bin/sh
#############################################################################
# NPC-PD2 project: get ChEMBL bioactivity data for compounds.
# 
# Where is pChEMBL score? Via REST? https://www.ebi.ac.uk/chembl/faq#faq41
# 
# Jeremy Yang
# 15 Feb 2015
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
#From PubChem, via CID, get InChI, InChIKey 
#
pubchemfile_raw="${cpdfile}.cid_pc.sdf"
if [ ! -e ${pubchemfile_raw} ]; then
	pug_rest_query.py --cids2sdf \
		--i ${cpdfile}.cid \
		--o ${pubchemfile_raw}
		--v
else
	printf "File exists, not overwritten: %s\n" ${pubchemfile_raw}
fi
#
inc_fields='PUBCHEM_COMPOUND_CID,PUBCHEM_IUPAC_INCHI,PUBCHEM_IUPAC_INCHIKEY,PUBCHEM_OPENEYE_ISO_SMILES'
sdf2csv.py \
	--i ${pubchemfile_raw} \
	--o ${pubchemfile_raw}.csv \
        --uniform --truncate --ignore_title \
        --include --fields "$inc_fields"
###
###
#NEW WAY: INSTEAD OF MERGE, USE SQL!
###
#Merge so CIDs linked to InChIKeys
#cpdfile_merged="${DATADIR}/NPC-OIDD-Compound_merged.csv"
#
#csv_utils.py \
#	--merge \
#	--i $cpdfile \
#	--coltag "PUBCHEM_CID" \
#	--iB ${pubchemfile_raw}.csv \
#	--coltagB "PUBCHEM_COMPOUND_CID" \
#	--o $cpdfile_merged
#
#
#Extract InChiKey:
#
csv_utils.py \
	--i ${pubchemfile_raw}.csv \
	--coltag "PUBCHEM_IUPAC_INCHIKEY" --extractcol \
	|grep -v '^$' \
	> ${pubchemfile_raw}.inchikey
###
###
#From Unichem, via InChIKey, get ChEMBL_ID:
#
unichemfile_raw="${pubchemfile_raw}.inchikey_unichem.csv"
if [ ! -e ${unichemfile_raw} ]; then
	unichem_query.py \
		--get_ids \
		--idfile ${cpdfile}.cid_pc.inchikey \
		--o ${unichemfile_raw} \
		--v
else
	printf "File exists, not overwritten: %s\n" ${unichemfile_raw}
fi
#
#Merge so InChIKeys linked to ChEMBL IDs
#csv_utils.py \
#	--merge \
#	--i ${cpdfile_merged} \
#	--iB ${unichemfile_raw} \
#	--coltag "PUBCHEM_IUPAC_INCHIKEY" \
#	--coltagB "inchikey" \
#	--overwrite_input_file
##
csv_utils.py \
	--i ${unichemfile_raw} \
	--coltag "chembl_id" --extractcol \
	|grep -v '^$' \
	> ${unichemfile_raw}.chemblid
#
###
#From ChEMBL, via ChEMBL_ID, get bioactivity summary data including protein targets:
#Slow!
#
chemblfile_raw="${cpdfile}.chembl_activity.csv"
if [ ! -e ${chemblfile_raw} ]; then
	chembl_query.py \
		--get_cpdactivity \
		--idfile ${unichemfile_raw}.chemblid \
		--o ${chemblfile_raw}
else
	printf "File exists, not overwritten: %s\n" ${chemblfile_raw}
fi
#
#
csv_utils.py --i ${chemblfile_raw} --coltag "assay_type" --colvalcounts
#csv_utils.py --i ${chemblfile_raw} --coltag "bioactivity_type" --colvalcounts
#csv_utils.py --i ${chemblfile_raw} --coltag "target_confidence" --colvalcounts
###
###
###
exit
###
#
#Create ChEMBL activity file:
#
csv_utils.py \
	--i ${cpdfile_merged} \
	--coltag "chembl_id" \
	--defilterbycol \
	--eqval "NULL" \
	--overwrite_input_file
#
chembl_activity_file="${DATADIR}/NPC-OIDD-Compound_chembl_activity.csv"
printf "ChEMBL activity file: %s\n" $chembl_activity_file
#
#Merge so ChEMBL IDs linked to activities:
csv_utils.py \
	--merge \
	--i ${cpdfile_merged} \
	--iB ${chemblfile_raw} \
	--coltag "chembl_id" \
	--coltagB "chemblId_query" \
	--overwrite_input_file
#
coltags="OIDD_ID NCGC_ID PUBCHEM_SID TRIVIAL_NAME SMILES PUBCHEM_CID PUBCHEM_COMPOUND_CID PUBCHEM_IUPAC_INCHI PUBCHEM_IUPAC_INCHIKEY PUBCHEM_OPENEYE_ISO_SMILES chembl_id chemblId_query assay_chemblid assay_description assay_type bioactivity_type target_chemblid target_confidence target_name units value"
csv_utils.py \
	--i ${cpdfile_merged} \
	--subsetcols --coltags "$coltags" \
	--o ${chembl_activity_file}
#
csv_utils.py \
	--i ${chembl_activity_file} \
	--filterbycol --coltag "assay_type" --eqval "B" \
	--overwrite_input_file
#
csv_utils.py \
	--i ${chembl_activity_file} \
	--filterbycol --coltag "target_confidence" --eqval "9" \
	--overwrite_input_file
###
#We would prefer to allow EC50, etc.
#csv_utils.py \
#	--i ${chembl_activity_file} \
#	--filterbycol --coltag "bioactivity_type" --eqval "IC50" \
#	--overwrite_input_file
#
##
#csv_utils.py --i ${chembl_activity_file} --coltag "units" --colvalcounts
#~19% are "nM".
#
csv_utils.py \
	--i ${chembl_activity_file} \
	--filterbycol --coltag "units" --eqval "nM" \
	--overwrite_input_file
#
###
#1uM maybe too strict for our purposes.
#csv_utils.py \
#	--i ${chembl_activity_file} \
#	--filterbycol --coltag "value" --maxval "1000" --numeric \
#	--overwrite_input_file
#
csv_utils.py --i ${chembl_activity_file} --size
csv_utils.py --i ${chembl_activity_file} --colcount_all
#
##
#Create ChEMBL target file:
chembl_target_file="${DATADIR}/NPC-OIDD-Compound_chembl_target.csv"
printf "ChEMBL target file: %s\n" $chembl_target_file
coltags="target_chemblid target_name"
csv_utils.py \
	--i ${chembl_activity_file} \
	--subsetcols --coltags "$coltags" \
	|sed -e '1d' \
	|sort -u \
	> ${chembl_target_file}
#
