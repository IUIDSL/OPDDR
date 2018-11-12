#!/bin/sh
#############################################################################
# For molecules -> activities -> assays -> targets
# Get ChEMBL RDF via Sparql endpoints.
#############################################################################
# Files produced: chembl_activity.ttl, chembl_target.ttl
#############################################################################
# https://www.ebi.ac.uk/rdf/documentation/sparql-endpoints
#############################################################################
# ISSUE: PubChem CID to ChEMBL ID should be via UniChem (FTP mapping file),
# not Inchi.
#############################################################################
# ISSUE: These queries return ALL activities for the substances,
# and ALL assays and activities for the targets.  This is more
# than we need, creating large files.  However the number of activities
# associating a substance and target is informative, adds evidence
# and confidence.
#############################################################################
# ISSUE: Only high-affinity activities should be returned.  Example query from
# https://www.ebi.ac.uk/rdf/documentation/chembl/examples:
###
### PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
### PREFIX sio: <http://semanticscience.org/resource/>
### 
### SELECT ?molecule
### WHERE
### {
###   <http://rdf.ebi.ac.uk/resource/chembl/protclass/CHEMBL_PC_1020> cco:hasTargetDescendant ?target .
###   ?target cco:hasAssay ?assay .
###   ?assay cco:hasActivity ?activity .
###   ?activity cco:hasMolecule ?molecule ;
###           cco:pChembl ?pchembl .
###   ?molecule  cco:highestDevelopmentPhase ?phase ;
###            sio:SIO_000008 ?prop_ro5 .
###   ?prop_ro5 a sio:CHEMINF_000312 ;
###   sio:SIO_000300 ?prop_ro5_val .
###   FILTER(?pchembl > 6 )
###   FILTER(?phase < 4 )
###   FILTER(?prop_ro5_val = 0 )
### }
#############################################################################
# Jeremy Yang
# 18 Jan 2016
#############################################################################
#
set -e
#
rqep="https://www.ebi.ac.uk/rdf/services/chembl/sparql"
#
DB="npcpd2"
SCHEMA="public"
#
DATADIR="data"
#
prologuefile="${DATADIR}/prologue.ttl"
###
# Molecule IDs:
midfile="${DATADIR}/chembl_molecule.id"
#
if [ ! -e "$midfile" ]; then
	psql -d $DB -qAt <<__EOF__ >${midfile}
SELECT DISTINCT
	u.chembl_mol_id
FROM
	unichem_chembl2pccid u
JOIN
	compound c ON c.pubchem_cid::VARCHAR(16) = u.pubchem_cid
ORDER BY
	u.chembl_mol_id
	;
__EOF__
fi
#
###
# ACTIVITIES (mol-act-ass-tgt):
# NOTE that activity file includes UniChem Pubchem-CID to Chembl-ID links.
###
#
act_ttlfile="${DATADIR}/chembl_activity.ttl"
#
printf "###File written by ${0}.\n" >${act_ttlfile}
cat ${prologuefile} >>${act_ttlfile}
printf "\n" >>${act_ttlfile}
#
psql -d $DB -qAt <<__EOF__ >>${act_ttlfile}
SELECT DISTINCT
	'substance:SID'||c.pubchem_sid||' skos:exactMatch chembl_molecule:'||u.chembl_mol_id||' .'
FROM
	compound c,
	unichem_chembl2pccid u
WHERE
	c.pubchem_cid::VARCHAR(16) = u.pubchem_cid
	;
__EOF__
#
printf "\n" >>${act_ttlfile}
#
act_tsvfile="${DATADIR}/chembl_activity.tsv"
rm -f $act_tsvfile
touch $act_tsvfile
#
act_tmpfile_rq="chembl_rq/z_act.rq"
#
n_mid=`cat ${midfile} |wc -l`
printf "Molecule IDs: %d\n" $n_mid
#
I="1"
while [ "$I" -le "$n_mid" ]; do
	chembl_id=`cat ${midfile} |sed "${I}q;d"`
	printf "%d. \"chembl_molecule:%s\"\n" $I $chembl_id
	I=`expr $I + 1`
	#
	cat <<__EOF__ >${act_tmpfile_rq}
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

SELECT "chembl_molecule:${chembl_id}" ?activity ?assay ?target ?pchembl
WHERE {
  ?activity a cco:Activity ;
     cco:hasMolecule chembl_molecule:${chembl_id} ;
     cco:hasAssay ?assay ;
     cco:pChembl ?pchembl .
  ?assay cco:hasTarget ?target .
  ?target a cco:SingleProtein .
  ?target cco:hasTargetComponent ?targetcmpt .
  ?targetcmpt cco:targetCmptXref ?uniprot .
  ?uniprot a cco:UniprotRef .
  FILTER(?pchembl > 3)
}
__EOF__
	#
	sparql_query.py --url "${rqep}" --rqfile ${act_tmpfile_rq} --fmt TSV --v \
	|sed -e '1,2d' \
	>>${act_tsvfile}
	#
done
#
###  Convert TSV to TTL:
#
# pchembl literal values represented as: "3.14"^^xsd:double
#
cat ${act_tsvfile} \
		|grep '^chembl_molecule' \
		|perl -pe 's/<a href="[^>]*>//g' \
		|perl -pe 's/<\/a>//g' \
		|perl -pe 's/^(\S*)\s*(\S*)\s*(\S*)\s*(\S*)\s*(\S*)/$1 cco:hasActivity chembl_activity:$2 .\nchembl_assay:$3 cco:hasActivity chembl_activity:$2 .\nchembl_target:$4 cco:hasAssay chembl_assay:$3 .\nchembl_activity:$2 cco:pChembl "$5"^^xsd:double .\n/' \
	>>${act_ttlfile}
#
#
#
###  Extract target ChemblIDs:
tidfile="${DATADIR}/chembl_target.id"
cat ${act_tsvfile} \
	|awk -F '\t' '{print $4}' \
	|perl -pe 's/^.*target\/(.*)".*$/$1/' \
	|sort -u \
	>${tidfile}
#
n_tid=`cat ${tidfile} |wc -l`
printf "Target IDs: %d\n" $n_tid
#
### Get target RDF:
tgt_ttlfile="${DATADIR}/chembl_target.ttl"
#
printf "###File written by ${0}.\n" >${tgt_ttlfile}
cat ${prologuefile} >>${tgt_ttlfile}
printf "\n" >>${tgt_ttlfile}
#
tgt_tsvfile="${DATADIR}/chembl_target.tsv"
rm -f $tgt_tsvfile
touch $tgt_tsvfile
#
tgt_tmpfile_rq="chembl_rq/z_tgt.rq"
#
I="1"
while [ "$I" -le "$n_tid" ]; do
	chembl_id=`cat ${tidfile} |sed "${I}q;d"`
	printf "%d. \"chembl_target:%s\"\n" $I $chembl_id
	I=`expr $I + 1`
	#
	cat <<__EOF__ >${tgt_tmpfile_rq}
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

SELECT "chembl_target:${chembl_id}" ?targetname ?targetcmpt ?uniprot
WHERE {
  chembl_target:${chembl_id} dcterms:title ?targetname .
  chembl_target:${chembl_id} cco:hasTargetComponent ?targetcmpt .
  ?targetcmpt cco:targetCmptXref ?uniprot .
  ?uniprot a cco:UniprotRef .
}
__EOF__
	#
	sparql_query.py --url "${rqep}" --rqfile ${tgt_tmpfile_rq} --fmt TSV --v \
	|sed -e '1,2d' \
	>>${tgt_tsvfile}
done
#
n_uniprot=`cat "${tgt_tsvfile}" |awk -F '\t' '{print $4}' |sort -u |wc -l`
printf "Distinct Uniprot IDs: %d\n" $n_uniprot
#
#
###  Convert TSV to TTL:
#
cat "${tgt_tsvfile}" \
		|grep '^chembl_target' \
		|perl -pe 's/<a href="[^>]*>//g' \
		|perl -pe 's/<\/a>//g' \
		|perl -pe 's/^(\S*)\t(.*)\t(\S*)\t(\S*)/$1 dcterms:title "$2" ;\n\tcco:hasTargetComponent chembl_targetcmpt:$3 .\nchembl_targetcmpt:$3 cco:targetCmptXref uniprot:$4 .\n/' \
	>>${tgt_ttlfile}
#
#
