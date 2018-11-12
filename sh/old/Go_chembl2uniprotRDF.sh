#!/bin/sh
#############################################################################
### Use ChEMBL API to get target summaries with Uniprot ID[s] (proteinAccession).
### for ChEMBL target IDs.  May be zero, 1, or 2+ UniProts per ChEMBL ID.
#############################################################################
#
#
###
#(Slow)
tgtcsv="data/chembl_target_summary.csv"
if [ ! -e "$tgtcsv" ]; then
	chembl_query.py \
		--v \
		--get_tgtsummary \
		--idfile data/chembl_target.id \
		--o $tgtcsv
fi
#
###
prolfile="data/prologue.ttl"
rdffile="data/chembl2uniprot.ttl"
#
cat $prolfile >${rdffile}
#
#First handle targetType "SINGLE PROTEIN" one-to-one mappings:
csv_utils.py \
	--i "$tgtcsv" \
	--subsetcols \
	--coltags 'chemblId_query,proteinAccession' \
	|sed -e '1d' \
        |grep '^CHEMBL[0-9][^,]*,[A-Z]' \
	|perl -pe 's/\r\n*/\n/g;' \
        |perl -pe 's/^([^,]*),(.*)/chembl_target:$1 cco:targetXref uniprot:$2 ./' \
        >>${rdffile}
#
###
###TO DO
#Next handle one-to-many mappings:
#Targets may consist of multiple targetcomponents, each with Uniprot xref.
#csv_utils.py \
#	--i "$tgtcsv" \
#	--subsetcols \
#	--coltags 'chemblId_query,proteinAccession' \
#	|sed -e '1d' \
#        |grep '^CHEMBL[0-9][^,]*,"[A-Z][A-Z0-9,][A-Z0-9,]*' \
#
