#!/bin/sh
#############################################################################
### Files produced: pubchem_assay.ttl, pubchem_substance.ttl, pubchem_endpoint.ttl
#############################################################################
#Current PubChem TTL is not correct (Sept 2015).
#Must correct by hack; see pc_rdf_fix.pl.
#############################################################################
#
DATADIR="data"
#
entrez_assay_search.pl \
	-ccrg \
	-out_summaries_xml $DATADIR/pubchem_assay_summary.xml \
	-out_summaries_csv $DATADIR/pubchem_assay_summary.csv \
	-out_aids $DATADIR/pubchem_assay.aid \
	-v
#
pubchem_rdf.py \
	--get_bioassay \
	--aidfile $DATADIR/pubchem_assay.aid \
	--o $DATADIR/pubchem_assay_raw.ttl \
	--ofmt TURTLE \
	--v
#
cat $DATADIR/prologue.ttl >$DATADIR/pubchem_assay.ttl
echo '' >>$DATADIR/pubchem_assay.ttl
cat $DATADIR/pubchem_assay_raw.ttl \
	|./pc_rdf_fix.pl \
	>>$DATADIR/pubchem_assay.ttl
#
csv_utils.py \
	--i ../data/NPC-OIDD-Compound.csv \
	--coltag "PUBCHEM_SID" \
	--extractcol \
	|grep -v '^$' \
	>$DATADIR/NPC-OIDD-Compound.sid
#
#NCGC00319023-01, Lotrafiban:
echo '170466632' >>$DATADIR/NPC-OIDD-Compound.sid
#
pubchem_rdf.py \
	--get_substance \
	--i $DATADIR/NPC-OIDD-Compound.sid \
	--o $DATADIR/pubchem_substance_raw.ttl \
	--ofmt TURTLE \
	--v
#
#
cat $DATADIR/prologue.ttl >$DATADIR/pubchem_substance.ttl
echo '' >>$DATADIR/pubchem_substance.ttl
cat $DATADIR/pubchem_substance_raw.ttl \
	|./pc_rdf_fix.pl \
	>>$DATADIR/pubchem_substance.ttl
###
pubchem_rdf.py \
	--get_endpoint \
	--i $DATADIR/NPC-OIDD-Compound.sid \
	--aidfile $DATADIR/pubchem_assay.aid \
	--ofmt TURTLE \
	--o $DATADIR/pubchem_endpoint_raw.ttl \
	--v
#
cat $DATADIR/prologue.ttl >$DATADIR/pubchem_endpoint.ttl
echo '' >>$DATADIR/pubchem_endpoint.ttl
cat $DATADIR/pubchem_endpoint_raw.ttl \
	|./pc_rdf_fix.pl \
	>>$DATADIR/pubchem_endpoint.ttl
#
###
#
