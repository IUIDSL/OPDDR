#!/bin/sh
#############################################################################
### Export local Reactome db as TTL RDF.
###
### Ref: http://www.ebi.ac.uk/rdf/services/reactome
### Ref: http://www.ebi.ac.uk/rdf/services/reactome/sparql
### Ref: http://www.reactome.org
###
### Classes:
###   biopax3:Pathway
###   biopax3:BiochemicalReaction
###   biopax3:Complex
###   biopax3:Protein
### Predicates:
###   biopax3:displayName
###   biopax3:pathwayComponent
###   biopax3:entityReference
#############################################################################
#
DB="scratch"
SCHEMA="reactome"
#
DATADIR="data"
rdffile="${DATADIR}/${SCHEMA}.ttl"
#
cat <<__EOF__ >${rdffile}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
@prefix owl: <http://www.w3.org/2002/07/owl#>
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>
@prefix dc: <http://purl.org/dc/elements/1.1/>
@prefix dcterms: <http://purl.org/dc/terms/>
@prefix foaf: <http://xmlns.com/foaf/0.1/>
@prefix skos: <http://www.w3.org/2004/02/skos/core#>
@prefix biopax3: <http://www.biopax.org/release/biopax-level3.owl#>
@prefix reactome: <http://identifiers.org/reactome/>
@prefix uniprot: <http://purl.uniprot.org/uniprot/>

__EOF__
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'reactome:'||rp.id ||' rdf:type biopax3:Pathway .'
FROM
	${SCHEMA}.reactomepathways rp
WHERE
	rp.organism = 'Homo sapiens'
	;
__EOF__
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'reactome:'||rp.id ||' rdfs:linkedTo '||'uniprot:'||u.uniprot||' .'
FROM
	${SCHEMA}.reactomepathways rp,
	${SCHEMA}.reactome2uniprot u
WHERE
	u.reactome_id = rp.id
	AND rp.organism = 'Homo sapiens'
	;
__EOF__
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'reactome:'||rpr.id_subclass ||' rdfs:subClassOf '||'reactome:'||rpr.id||' .'
FROM
	reactome.reactomepathwaysrelation rpr,
	reactome.reactomepathways rp
WHERE
	rpr.id = rp.id
	AND rp.organism = 'Homo sapiens'
	;
__EOF__
#
