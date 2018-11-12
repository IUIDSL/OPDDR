#!/bin/sh
#
#(TTL format not supported by this endpoint unfortunately.)
#
rqep="http://www.ebi.ac.uk/rdf/services/reactome/sparql"
#
set -x
#
#sparql_query.py --url "${rqep}" --rqfile q1.rq --fmt TTL >q1.out
#sparql_query.py --url "${rqep}" --rqfile q2.rq --fmt TTL >q2.out
#
sparql_query.sh -url "${rqep}" -i q1.rq >q1.out
sparql_query.sh -url "${rqep}" -i q2.rq >q2.out
#
