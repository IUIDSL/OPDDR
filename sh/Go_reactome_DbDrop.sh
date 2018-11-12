#!/bin/sh
#
DB="scratch"
SCHEMA="reactome"
#
#
tables=`psql -q -d $DB -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema='$SCHEMA'"`
#
for table in $tables ; do
	if [ `echo "$table" |grep -i 'reactome'` ]; then
		sql="DROP TABLE ${SCHEMA}.${table} CASCADE"
		echo "$sql"
		psql ${DB} -c "$sql"
	fi
done
#
