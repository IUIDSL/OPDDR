#!/bin/sh
#############################################################################
# Get ChEMBL RDF via Sparql endpoints.
#
# https://www.ebi.ac.uk/rdf/documentation/sparql-endpoints
#############################################################################
#
rqep="https://www.ebi.ac.uk/rdf/services/chembl/sparql"
#
DB="scratch"
SCHEMA="npcpd2"
#
idfile="data/chembl_target.id"
#
psql -d $DB -qAt <<__EOF__ >${idfile}
SELECT DISTINCT
	a.target_chemblid
FROM
	npcpd2.compound c,
	npcpd2.pubchem_cid2inchi p,
	npcpd2.unichem_inchi2chembl u,
	npcpd2.chembl_activity a
WHERE
	c.pubchem_cid::VARCHAR(16) = p.pubchem_compound_cid
	AND p.pubchem_iupac_inchikey = u.inchikey
	AND u.chembl_id = a.chemblid_query
	AND a.units = 'nM'
	;
__EOF__
#
n_id=`cat ${idfile} |wc -l`
printf "IDs: %d\n" $n_id
#
ttlfile="data/chembl_target_sparql.ttl"
#
if [ -e "$ttlfile" ]; then
	rm $ttlfile
fi
touch $ttlfile
#
#
I="1"
while [ "$I" -le "$n_id" ]; do
	chembl_id=`cat ${idfile} |sed "${I}q;d"`
	printf "%d. \"%s\"\n" $I $chembl_id
	I=`expr $I + 1`
	#
	cat <<__EOF__ >data/z.rq
PREFIX chembl_target: <http://rdf.ebi.ac.uk/resource/chembl/target/>

SELECT ?s ?p ?o
WHERE {
   chembl_target:${chembl_id} ?p ?o .
}
__EOF__
	#
	#printf "QUERY = chembl_target:%s\n" "${chembl_id}" >>${ttlfile}
	printf "\n" >>${ttlfile}
	sparql_query.sh -url "${rqep}" -i data/z.rq -ofmt TTL -v >>${ttlfile}
	#
#	if [ "$I" -eq 10 ]; then
#		break
#	fi
	#
done
#
#rm data/z.rq
#
