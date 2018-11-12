#!/bin/sh
#############################################################################
### Get one assay RDF.
#############################################################################
#
set -e
#
if [ $# -lt 1 ]; then
	printf "ERROR: Syntax: %s CHEMBLID\n" `basename $0`
	exit
fi
CHEMBLID="$1"
#
rqep="https://www.ebi.ac.uk/rdf/services/chembl/sparql"
#
DATADIR="data"
#
prologuefile="${DATADIR}/prologue.ttl"
#
ass_tmpfile_rq="chembl_rq/z_ass.rq"
#
cat <<__EOF__ >${ass_tmpfile_rq}
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>

PREFIX chembl_molecule: <http://rdf.ebi.ac.uk/resource/chembl/molecule/>
PREFIX chembl_activity: <http://rdf.ebi.ac.uk/resource/chembl/activity/>
PREFIX chembl_assay: <http://rdf.ebi.ac.uk/resource/chembl/assay/>
PREFIX chembl_target: <http://rdf.ebi.ac.uk/resource/chembl/target/>
PREFIX chembl_targetcmpt: <http://rdf.ebi.ac.uk/resource/chembl/targetcomponent/>

SELECT "chembl_assay:${CHEMBLID}" ?target
WHERE {
  chembl_assay:${CHEMBLID} cco:hasTarget ?target .
}
__EOF__
#
set -x
#
sparql_query.py --url "${rqep}" --rqfile ${ass_tmpfile_rq} --v --fmt RDF
#
#
