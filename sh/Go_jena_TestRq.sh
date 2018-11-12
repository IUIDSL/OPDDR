#!/bin/sh
#
rdffiles="data/npcpd2_merged.ttl,data/bao_vocabulary_assay.owl"
###
rqfiles=`ls rq/*.rq`
#
printf "rqfiles: %s\n" "$rqfiles"
#
for rqfile in $rqfiles ; do
	ofile="data/`basename ${rqfile}`.out"
	printf "%s -> %s\n" "${rqfile}" "${ofile}"
	jena_utils.sh -query_rdf -dlang TTL -v \
		-rdffiles "$rdffiles" \
		-rqfile ${rqfile} \
		-o ${ofile}
	printf "Output lines: %d\n\n" `cat data/${rqfile}.out |wc -l`
done
#
#
###
#
