#!/bin/sh
#
###
#Not working; why:
###
# /etc/init.d/fuseki start
#

###
#Works ok:
###
#sudo -E -u fuseki $FUSEKI_HOME/fuseki-server 


###
rest_request.py --url 'http://localhost:3030/$/server'
#
rest_request.py --url 'http://localhost:3030/$/datasets'
#
rest_request.py --url 'http://localhost:3030/$/stats/npcpd2'
rest_request.py --url 'http://localhost:3030/$/datasets/npcpd2'
#
###
#POST TTL file to upload:
###
rest_request.py \
	--url 'http://localhost:3030/$/datasets/npcpd2/data' \
	--body data/npcpd2.ttl \
	--body_raw \
	--headers 'Content-Type:application/octet-stream' \
	--vv
#
#
ttlfiles="\
data/npcpd2.ttl \
data/npcpd2_bao_annotations.ttl \
data/ncats2pubchem_substance.ttl \
data/oidd2pubchem_assay.ttl \
data/oidd_assay.ttl \
data/pubchem_pd2_assay.ttl \
data/chembl2uniprot.ttl \
data/chembl_activity.ttl \
data/chembl_target.ttl \
"
#
###
#
sparql_query.sh -url 'http://localhost:3030/scratch/query' -i rq/assay_01.rq 
#
