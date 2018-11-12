#!/bin/sh
#############################################################################
### Merge TTL files into one.
#############################################################################
#
outfile="data/npcpd2_merged.ttl"
#
prolfile="data/prologue.ttl"
#
cat $prolfile >$outfile
#
#
ttlfiles="\
data/npcpd2_assay.ttl \
data/npcpd2_bao.ttl \
data/npcpd2_substance.ttl \
data/pubchem_assay.ttl \
data/pubchem_substance.ttl \
data/pubchem_endpoint.ttl \
data/chembl_target.ttl \
data/chembl_activity.ttl \
"
#
for ttlfile in $ttlfiles ; do
	printf "adding: ${ttlfile}\n"
	cat ${ttlfile} |grep -v '^@' >>$outfile
done
#
printf "output: ${outfile}\n"
#
#
###
echo 'Testing merged file...'
#
rdffiles="data/npcpd2_merged.ttl,data/chembl_cco.ttl,data/bao_vocabulary_assay.owl,data/pubchem_vocabulary.owl"
#
set -x
#
jena_utils.sh -rdffiles "$rdffiles" -describe_rdf
#
