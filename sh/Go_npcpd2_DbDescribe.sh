#!/bin/sh
#
DB="npcpd2"
SCHEMA="public"
#
tables=`psql -d $DB -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema='$SCHEMA'"`
#
for table in $tables ; do
	echo $table
	psql -d $DB -c "SELECT column_name,data_type FROM information_schema.columns WHERE table_schema='$SCHEMA' AND table_name = '$table'"
	psql -d $DB -c "SELECT count(*) AS "${table}_count" FROM $SCHEMA.$table"

done
