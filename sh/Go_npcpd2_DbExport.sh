#!/bin/sh
#
DB="npcpd2"
SCHEMA="public"
#
###
#Assays:
psql -d $DB -F ',' -qAt \
	-f sql/assay_export.sql \
	-o data/assay_export.csv
###
#Chembl:
psql -d $DB -F ',' -qAt \
	-f sql/chembl_activity_export.sql \
	-o data/chembl_db_activity_export.csv
#
printf "activities: %d\n" `cat data/chembl_db_activity_export.csv |wc -l`
###
psql -d $DB -F ',' -qAt \
	-f sql/chembl_target_export.sql \
	-o data/chembl_db_target_export.csv
#
printf "targets: %d\n" `cat data/chembl_db_target_export.csv |wc -l`
###
psql -d $DB -F ',' -qAt \
	-f sql/pc2chembl_mol_export.sql \
	-o data/pc2chembl_mol_export.csv
#
printf "pc2chembl molecule links: %d\n" `cat data/pc2chembl_mol_export.csv |wc -l`
#
