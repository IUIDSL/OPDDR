#!/bin/sh
#############################################################################
### Export local NPCPD2 db as TTL RDF.
###  * assay (AID) links to OIDD namespace.
###  * substance (SID) links to NCATS namespace.
###  * BAO annotations from curated GDoc.
### 
### This script should NOT duplicate RDF available directly from PubChem
### or from ChEMBL.
#############################################################################
### Files produced: npcpd2_assay.ttl, npcpd2_substance.ttl, npcpd2_bao.ttl
#############################################################################
### Jeremy Yang
###  3 Jul 2015
#############################################################################
#
DB="npcpd2"
SCHEMA="public"
#
DATADIR="data"
#
#
prologuefile="${DATADIR}/prologue.ttl"
cat <<__EOF__ >${prologuefile}
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix obo: <http://purl.obolibrary.org/obo/> .
@prefix sio: <http://semanticscience.org/resource/> .
@prefix oidd_assay: <http://openinnovation.lilly.com/bioassay#> .
@prefix ncats_sample: <http://rdf.ncats.nih.gov/ncgc/sample/> .
@prefix opddr: <http://rdf.ncats.nih.gov/opddr/> .
@prefix bao: <http://www.bioassayontology.org/bao#> .
@prefix bioassay: <http://rdf.ncbi.nlm.nih.gov/pubchem/bioassay/> .
@prefix substance: <http://rdf.ncbi.nlm.nih.gov/pubchem/substance/> .
@prefix compound: <http://rdf.ncbi.nlm.nih.gov/pubchem/compound/> .
@prefix measureg: <http://rdf.ncbi.nlm.nih.gov/pubchem/measuregroup/> .
@prefix endpoint: <http://rdf.ncbi.nlm.nih.gov/pubchem/endpoint/> .
@prefix source: <http://rdf.ncbi.nlm.nih.gov/pubchem/source/> .
@prefix descr: <http://rdf.ncbi.nlm.nih.gov/pubchem/descriptor/> .
@prefix syno: <http://rdf.ncbi.nlm.nih.gov/pubchem/synonym/> .
@prefix reference: <http://rdf.ncbi.nlm.nih.gov/pubchem/reference/> .
@prefix vocabulary: <http://rdf.ncbi.nlm.nih.gov/pubchem/vocabulary#> .
@prefix cco: <http://rdf.ebi.ac.uk/terms/chembl#> .
@prefix chembl_molecule: <http://rdf.ebi.ac.uk/resource/chembl/molecule/> .
@prefix chembl_activity: <http://rdf.ebi.ac.uk/resource/chembl/activity/> .
@prefix chembl_assay: <http://rdf.ebi.ac.uk/resource/chembl/assay/> .
@prefix chembl_target: <http://rdf.ebi.ac.uk/resource/chembl/target/> .
@prefix chembl_targetcmpt: <http://rdf.ebi.ac.uk/resource/chembl/targetcomponent/> .
@prefix biopax3: <http://www.biopax.org/release/biopax-level3.owl#> .
@prefix reactome: <http://identifiers.org/reactome/> .
@prefix uniprot: <http://purl.uniprot.org/uniprot/> .

__EOF__
#
#############################################################################
# Substance-measuregroup links.
# obo:BFO_0000056 means "participates in at some time".
# WHOA!  THESE LINKS IN PUBCHEM RDF RIGHT???  OBTAIN DIRECTLY?
# YES: SEE pubchem_pd2_endpoint.ttl
# MEASUREGROUP LINKS in pubchem_pd2_assay.ttl and pubchem_pd2_substance.ttl.
###
#rdffile="${DATADIR}/${SCHEMA}_results.ttl"
#printf "Writing %s\n" ${rdffile}
#
#printf "###File written by ${0}.\n" >${rdffile}
#cat ${prologuefile} >>${rdffile}
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'substance:SID'||c.pubchem_sid||' obo:BFO_0000056 measureg:AID'||a.pubchem_aid||' .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	;
#__EOF__
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'measureg:AID'||a.pubchem_aid||' obo:OBI_0000299 endpoint:SID'||c.pubchem_sid||'_AID'||a.pubchem_aid||' .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	;
#__EOF__
#
#
###    outcome     | result_count 
###----------------+--------------
### See Manuscript |         1003
### INACTIVE       |        56233
### NULL           |          131
### ACTIVE         |         8577
#
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'endpoint:SID'||c.pubchem_sid||'_AID'||a.pubchem_aid||' vocabulary:PubChemAssayOutcome vocabulary:active .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	AND r.outcome = 'ACTIVE'
#	;
#__EOF__
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'endpoint:SID'||c.pubchem_sid||'_AID'||a.pubchem_aid||' vocabulary:PubChemAssayOutcome vocabulary:inactive .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	AND r.outcome = 'INACTIVE'
#	;
#__EOF__
##
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'endpoint:SID'||c.pubchem_sid||'_AID'||a.pubchem_aid||' vocabulary:PubChemAssayOutcome vocabulary:unspecified .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	AND r.outcome IS NULL
#	;
#__EOF__
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'endpoint:SID'||c.pubchem_sid||'_AID'||a.pubchem_aid||' vocabulary:PubChemAssayOutcome vocabulary:inconclusive .'
#FROM
#	results r,
#	compound c,
#	assay a
#WHERE
#	r.ncgc_id = c.ncgc_id
#	AND r.oidd_assay = a.oidd_id
#	AND r.outcome ILIKE 'See Manuscript'
#	;
#__EOF__
#
#############################################################################
# Assay links.
###
rdffile="${DATADIR}/${SCHEMA}_assay.ttl"
printf "Writing %s\n" ${rdffile}
#
printf "###File written by ${0}.\n" >${rdffile}
cat ${prologuefile} >>${rdffile}
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'bioassay:AID'||a.pubchem_aid ||' skos:exactMatch oidd_assay:'||a.oidd_id||' .' AS "link"
FROM
	assay a
ORDER BY link
	;
__EOF__
#
#Fix bare backslashes in names.
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'bioassay:AID'||a.pubchem_aid ||' rdfs:label "'||REPLACE(a.name,'\\','_')||'" .'
#FROM
#	assay a
#	;
#__EOF__
#
#psql -q -d $DB -tA <<__EOF__ >>${rdffile}
#SELECT DISTINCT
#	'bioassay:AID'||a.pubchem_aid ||' bao:BAO_0000209  measureg:AID'||a.pubchem_aid||' .'
#FROM
#	assay a
#	;
#__EOF__
###
#
#############################################################################
#Substance: SID to NCGC links.
###
rdffile="${DATADIR}/npcpd2_substance.ttl"
printf "Writing %s\n" ${rdffile}
#
printf "###File written by ${0}.\n" >${rdffile}
cat ${prologuefile} >>${rdffile}
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'substance:SID'||c.pubchem_sid ||' skos:exactMatch ncats_sample:'||c.ncgc_id||' .'
FROM
	compound c
	;
__EOF__
#
#############################################################################
# Manual BAO annotations.
# Exported from curated GDoc to CSV.
###
rdffile="${DATADIR}/npcpd2_bao.ttl"
printf "Writing %s\n" ${rdffile}
#
printf "###File written by ${0}.\n" >${rdffile}
cat ${prologuefile} >>${rdffile}
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'bioassay:AID'||a.pubchem_aid ||' rdf:type bao:'||a.bao_class||' .'
FROM
	assay a
	;
__EOF__
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'bioassay:AID'||a.pubchem_aid ||' rdf:type bao:'||a.bao_type||' .'
FROM
	assay a
	;
__EOF__
#
psql -q -d $DB -tA <<__EOF__ >>${rdffile}
SELECT DISTINCT
	'bioassay:AID'||a.pubchem_aid ||' rdf:type bao:'||a.bao_format||' .'
FROM
	assay a
	;
__EOF__
#
##############################################################################
