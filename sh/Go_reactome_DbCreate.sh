#!/bin/sh
#############################################################################
### Go_reactome_CreateDb.sh - 
### 
### Jeremy Yang
### 16 Apr 2015
#############################################################################
#
set -e
#
DB="scratch"
SCHEMA="reactome"
#
PSQLOPTS="-q"
#
psql $DB <<__EOF__
CREATE SCHEMA $SCHEMA;
COMMENT ON SCHEMA $SCHEMA IS 'Reactome: local Db' ;
__EOF__
#############################################################################
#
DATADIR="data"
#
csv_utils.py \
	--i $DATADIR/ReactomePathways.txt \
	--o $DATADIR/ReactomePathways.csv \
	--tsv2csv
csv_utils.py \
	--i $DATADIR/ReactomePathways.csv \
	--addheader "id,name,organism" \
	--overwrite_input_file
csv_utils.py \
	--i $DATADIR/ReactomePathwaysRelation.txt \
	--o $DATADIR/ReactomePathwaysRelation.csv \
	--tsv2csv
csv_utils.py \
	--i $DATADIR/ReactomePathwaysRelation.csv \
	--addheader "id,id_subclass" \
	--overwrite_input_file
csv_utils.py \
	--i $DATADIR/UniProt2Reactome.txt \
	--o $DATADIR/reactome2uniprot.csv \
	--tsv2csv
csv_utils.py --i $DATADIR/reactome2uniprot.csv --deletecol --col 6 --overwrite_input_file
csv_utils.py --i $DATADIR/reactome2uniprot.csv --deletecol --col 5 --overwrite_input_file
csv_utils.py --i $DATADIR/reactome2uniprot.csv --deletecol --col 4 --overwrite_input_file
csv_utils.py --i $DATADIR/reactome2uniprot.csv --deletecol --col 3 --overwrite_input_file
csv_utils.py \
	--i $DATADIR/reactome2uniprot.csv \
	--addheader "uniprot,reactome_id" \
	--overwrite_input_file
###
###
csvfiles="$DATADIR/ReactomePathwaysRelation.csv $DATADIR/ReactomePathways.csv $DATADIR/reactome2uniprot.csv"
for csvfile in $csvfiles ; do
	csv2sql.py \
		--i $csvfile \
		--dbschema "$SCHEMA" \
		--fixtags \
		--create \
		--o ${csvfile}_create.sql
	#
	psql $PSQLOPTS $DB -f ${csvfile}_create.sql
	#
	csv2sql.py \
		--i $csvfile \
		--dbschema "$SCHEMA" \
		--fixtags \
		--insert \
		--o ${csvfile}_insert.sql
	#
	psql $PSQLOPTS $DB -f ${csvfile}_insert.sql
	#
done
#
