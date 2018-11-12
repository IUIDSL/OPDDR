#!/bin/sh
#
rdffiles="data/npcpd2_merged.ttl,data/bao_vocabulary_assay.owl,data/pubchem_vocabulary.owl,data/chembl_cco.ttl"
###
if [ $# -lt 1 ]; then
	printf "Syntax: $0 RQFILE\n"
	exit
fi
###
rqfile=$1
printf "%s\n" "${rqfile}"
cat "${rqfile}"
#
set -x
jena_utils.sh -query_rdf -dlang TTL -v \
	-rdffiles "$rdffiles" \
	-rqfile ${rqfile}
#
