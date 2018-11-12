#!/bin/sh
#
if [ "`uname -s`" = "Darwin" ]; then
	APPDIR="/Users/app"
elif [ "`uname -s`" = "Linux" ]; then
	APPDIR="/home/app"
else
	APPDIR="/home/app"
fi
#
DATADIR="data"
#
##################################
#File from OIDD/Natalie:
rawcsv_oidd="${DATADIR}/NCATS_cpds_w_metadata.csv"
#
set -x
#
csv_utils.py --i $rawcsv_oidd --list_tags
#
csv_utils.py --i $rawcsv_oidd --counts
#
##################################
#File from NCATS:
rawsdf="${DATADIR}/npc-dump-1.2-04-25-2012.sdf"
#
##################################
###ChemAxon way:
#MOLCONVERT="$APPDIR/ChemAxon/JChem/bin/molconvert"
#
#$MOLCONVERT 'smiles:r1+TID:URL:CompoundCAS:Synonyms' \
#	$rawsdf \
#	-v -g \
#	-o ${DATADIR}/npc_cpds_sd.smiles
#
#cat ${DATADIR}/npc_cpds_smi.csv \
#	| perl -pe 's/\\n[^\t]\t/\t/;' \
#	| perl -pe 's/\\n[^\t]*"\n/"\n/;' \
#	| perl -pe 's/\t/,/g;' \
#	| perl -pe 's/^#SMILES/SMILES/;' \
#	>${DATADIR}/npc_cpds_sd_smiles.csv
#
#csv_utils.py --counts --i ${DATADIR}/npc_cpds_sd_smiles.csv
#
#
##################################
###OE way (better):
### --truncate keeps only 1st line of multiline values so we can handle CSV better.
sdf2csv.py --i $rawsdf \
	--truncate \
	--o ${DATADIR}/npc-dump-1.2-04-25-2012.csv
#
csv_utils.py --counts --i ${DATADIR}/npc-dump-1.2-04-25-2012.csv
#
