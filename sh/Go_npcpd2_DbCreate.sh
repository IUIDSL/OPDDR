#!/bin/sh
#############################################################################
### Go_npcpd2_CreateDb.sh - 
### 
#############################################################################
### NOTE: INCHI links are obsoleted in favor of UniChem CID-ChemblID links.
### NOTE: Re. CID-ChemblID links, previously wasteful/confusing to include all.
#############################################################################
### Jeremy Yang
### 15 May 2016
#############################################################################
#
set -e
set -x
#
DB="npcpd2"
SCHEMA="public"
#
###
INFILE_ASS="data/NPC-OIDD-Assay.csv"
INFILE_CPD="data/NPC-OIDD-Compound.csv"
INFILE_RES="data/NPC-OIDD-Results.csv"
#
#
###
createdb $DB
#
psql -d $DB -c "COMMENT ON DATABASE $DB IS 'OPDDR (NCATS-Lilly) staging db'"
#
###
#First do easy stuff, finally compound table.
###
#Assays:
###
csv2sql.py \
	--i $INFILE_ASS \
	--schema "$SCHEMA" \
	--tablename "assay" \
	--fixtags \
	--coltypes "INT,,,,,,,,,,," \
	--create \
	--o ${INFILE_ASS}_create.sql
csv2sql.py \
	--i $INFILE_ASS \
	--tablename "assay" \
	--schema "$SCHEMA" \
	--fixtags \
	--coltypes "INT,,,,,,,,,,," \
	--insert \
	--o ${INFILE_ASS}_insert.sql
#
psql -d $DB -f ${INFILE_ASS}_create.sql
psql -q -d $DB -f ${INFILE_ASS}_insert.sql
###
#Results:
###
csv_utils.py --i $INFILE_RES --list_tags
#
csv2sql.py \
	--i $INFILE_RES \
	--schema "$SCHEMA" \
	--tablename "results" \
	--fixtags \
	--coltypes "INT,,FLOAT,,,,,,," \
	--create \
	--o ${INFILE_RES}_create.sql
#
psql -q -d $DB -f ${INFILE_RES}_create.sql
#
csv2sql.py \
	--i $INFILE_RES \
	--schema "$SCHEMA" \
	--tablename "results" \
	--fixtags \
	--coltypes "INT,,FLOAT,,,,,,," \
	--insert \
	--o ${INFILE_RES}_insert.sql
#
psql -q -d $DB -f ${INFILE_RES}_insert.sql
#
#
###
#ChEMBL (and UniChem) data:
#(See Go_npcpd2_CsvChembl.sh.)
###
#csvfiles="data/chembl_target.csv data/unichem_chembl2pccid.csv"
csvfiles="data/chembl_target.csv data/cid2chemblid.csv"
for csvfile in $csvfiles ; do
	csv2sql.py \
		--i $csvfile \
		--schema "$SCHEMA" \
		--fixtags \
		--create \
		--o ${csvfile}_create.sql
	#
	psql -d $DB -f ${csvfile}_create.sql
	#
	csv2sql.py \
		--i $csvfile \
		--schema "$SCHEMA" \
		--fixtags \
		--insert \
		--o ${csvfile}_insert.sql
	#
	psql -q -d $DB -f ${csvfile}_insert.sql
	#
done
#
#psql -q -d $DB -c "COMMENT ON TABLE unichem_chembl2pccid IS 'From downloaded unichem_src1src22.txt'"
psql -q -d $DB -c "COMMENT ON TABLE cid2chemblid IS 'From downloaded unichem_src1src22.txt, selected PubChem CIDs.'"
#
#
#Need numerical types to query activity:
#
csvfile="data/chembl_activity.csv"
csv2sql.py \
	--i $csvfile \
	--schema "$SCHEMA" \
	--fixtags \
	--create \
	--o ${csvfile}_create.sql
#
psql -d $DB -f ${csvfile}_create.sql
#
csv2sql.py \
	--i $csvfile \
	--schema "$SCHEMA" \
	--fixtags \
	--insert \
	--o ${csvfile}_insert.sql
#
psql -q -d $DB -f ${csvfile}_insert.sql
#
psql -d $DB -c "ALTER TABLE chembl_activity ADD COLUMN tmp FLOAT"
psql -d $DB -tAc "UPDATE chembl_activity SET tmp = standard_value::FLOAT WHERE standard_value != ''"
psql -d $DB -c "ALTER TABLE chembl_activity DROP COLUMN standard_value"
psql -d $DB -c "ALTER TABLE chembl_activity RENAME COLUMN tmp TO standard_value"
#
###
#Compounds:
###
#psql -d $DB <<__EOF__
#CREATE TABLE compound (
#	id BIGINT PRIMARY KEY,
#	ncgc_id VARCHAR(16),
#	pubchem_sid BIGINT,
#	pubchem_cid BIGINT,
#	cansmi VARCHAR(2048),
#	isosmi VARCHAR(2048),
#	mf VARCHAR(128),
#	name VARCHAR(512)
#) ;
#__EOF__
#
#cat $INFILE_CPD \
#	|sed -e '1d' \
#        |perl -pe "s/\"(\\d*)\",\"([^\"]*)\",\"(\\d*)\",\"([^\"]*)\",\"([^\"]*)\",\"(\\d*).*$/INSERT INTO $SCHEMA.compound (id,ncgc_id,pubchem_sid,pubchem_cid) VALUES (\$1,'\$2',\$3,\$6);/" \
#	|sed -e 's/,,/,NULL,/g' \
#	|sed -e 's/(,/(NULL,/' \
#	|sed -e 's/,)/,NULL)/' \
#	>data/compound_ids.sql
#psql -q -d $DB -f data/compound_ids.sql
##
#cat $INFILE_CPD \
#	|sed -e '1d' \
#        |perl -pe "s/\"(\\d*)\",\"([^\"]*)\",\"(\\d*)\",\"([^\"]*)\",\"([^\"]*)\",\"(\\d*).*$/UPDATE $SCHEMA.compound SET isosmi = '\$5' WHERE id = \$1 ;/" \
#	|perl -pe "s/\\\\/'||E'\\\\\\\\'||'/g" \
#	>data/compound_smiles.sql
#psql -q -d $DB -f data/compound_smiles.sql
##
#cat $INFILE_CPD \
#	|sed -e '1d' \
#	|perl -pe "s/'/'||E'\\\\''||'/g" \
#        |perl -pe "s/\"(\\d*)\",\"([^\"]*)\",\"(\\d*)\",\"([^\"]*)\",\"([^\"]*)\",\"(\\d*).*$/UPDATE $SCHEMA.compound SET name = '\$4' WHERE id = \$1 ;/" \
#	>data/compound_names.sql
#psql -q -d $DB -f data/compound_names.sql
#
###
csv2sql.py \
	--i $INFILE_CPD \
	--schema "$SCHEMA" \
	--tablename "compound" \
	--fixtags \
	--create \
	--o ${INFILE_CPD}_create.sql
#
psql -d $DB -f ${INFILE_CPD}_create.sql
#
csv2sql.py \
	--i $INFILE_CPD \
	--schema "$SCHEMA" \
	--tablename "compound" \
	--fixtags \
	--insert \
	--o ${INFILE_CPD}_insert.sql
#
psql -q -d $DB -f ${INFILE_CPD}_insert.sql
#
psql -d $DB -c "ALTER TABLE compound ADD COLUMN id BIGINT"
psql -d $DB -c "ALTER TABLE compound ADD COLUMN cansmi VARCHAR(2048)"
psql -d $DB -c "ALTER TABLE compound ADD COLUMN mf VARCHAR(128)"
#
psql -d $DB -tAc "UPDATE compound SET id = oidd_id::BIGINT"
psql -d $DB -c "ALTER TABLE compound ADD PRIMARY KEY (id)"
#
psql -d $DB -tAc "UPDATE compound SET name = trivial_name"
psql -d $DB -c "ALTER TABLE compound RENAME COLUMN trivial_name TO name"
#
psql -d $DB -c "ALTER TABLE compound ADD COLUMN tmp BIGINT"
psql -d $DB -tAc "UPDATE compound SET tmp = pubchem_sid::BIGINT WHERE pubchem_sid != ''"
psql -d $DB -c "ALTER TABLE compound DROP COLUMN pubchem_sid"
psql -d $DB -c "ALTER TABLE compound RENAME COLUMN tmp TO pubchem_sid"
#
psql -d $DB -c "ALTER TABLE compound ADD COLUMN tmp BIGINT"
psql -d $DB -tAc "UPDATE compound SET tmp = pubchem_cid::BIGINT WHERE pubchem_cid != ''"
psql -d $DB -c "ALTER TABLE compound DROP COLUMN pubchem_cid"
psql -d $DB -c "ALTER TABLE compound RENAME COLUMN tmp TO pubchem_cid"
#
psql -d $DB -tAc "SELECT count(*) FROM compound"
###
#
#############################################################################
### NEW (June 2015):
# Load external links.  So RDF export can be simpler.
###
###  * OIDD_ID to SID
###  * BAO annotations from curated GDoc
#############################################################################
#
# exported from curated GDoc to CSV:
npcpd2_assaymetafile="data/NPC-PD2_assay_meta.csv"
#
#############################################################################
###
psql -q -d $DB -c "ALTER TABLE $SCHEMA.assay ADD COLUMN pubchem_aid BIGINT"
#
sqlfile="data/assay_oidd2pubchem.sql"
rm -f $sqlfile ; touch $sqlfile
#
csv_utils.py \
	--i ${npcpd2_assaymetafile} \
	--subsetcols \
	--coltags 'oidd_id,AID' \
	|sed -e '1d' \
	|grep '^[0-9].*,[0-9]' \
	|perl -pe "s/^([^,]*),(\S*)/UPDATE $SCHEMA.assay SET pubchem_aid = \$2 WHERE oidd_id = \$1 ;/" \
	>>$sqlfile
#
psql -q -d $DB -f ${sqlfile}
#
#############################################################################
# Manual BAO annotations.
# Exported from curated GDoc to CSV.
###
psql -q -d $DB -c "ALTER TABLE $SCHEMA.assay ADD COLUMN bao_class VARCHAR(16)"
psql -q -d $DB -c "ALTER TABLE $SCHEMA.assay ADD COLUMN bao_type VARCHAR(16)"
psql -q -d $DB -c "ALTER TABLE $SCHEMA.assay ADD COLUMN bao_format VARCHAR(16)"
#
sqlfile="data/assay_bao.sql"
rm -f $sqlfile ; touch $sqlfile
#
csv_utils.py \
	--i ${npcpd2_assaymetafile} \
	--subsetcols \
	--coltags 'AID,BAO_class' \
	|sed -e '1d' \
	|grep '^[0-9].*,BAO' \
	|perl -pe "s/^([^,]*),([^:]*):.*\$/UPDATE $SCHEMA.assay SET bao_class = \'\$2\' WHERE pubchem_aid = \$1 ;/" \
	>>$sqlfile
#
csv_utils.py \
	--i ${npcpd2_assaymetafile} \
	--subsetcols \
	--coltags 'AID,BAO_type' \
	|sed -e '1d' \
	|grep '^[0-9].*,BAO' \
	|perl -pe "s/^([^,]*),([^:]*):.*\$/UPDATE $SCHEMA.assay SET bao_type = \'\$2\' WHERE pubchem_aid = \$1 ;/" \
	>>$sqlfile
#
csv_utils.py \
	--i ${npcpd2_assaymetafile} \
	--subsetcols \
	--coltags 'AID,BAO_format' \
	|sed -e '1d' \
	|grep '^[0-9].*,BAO' \
	|perl -pe "s/^([^,]*),([^:]*):.*\$/UPDATE $SCHEMA.assay SET bao_format = \'\$2\' WHERE pubchem_aid = \$1 ;/" \
	>>$sqlfile
#
psql -q -d $DB -f ${sqlfile}
#
###
#############################################################################
#RDKit:
exit
#
sudo -u postgres psql -d $DB -c 'create extension rdkit'
#
psql -d $DB -c "ALTER TABLE compound ADD COLUMN mol mol"
psql -d $DB -c "UPDATE compound SET mol = mol_from_smiles(smiles::cstring)"
psql -d $DB -c "CREATE INDEX molidx ON compound USING gist(mol)"
psql -d $DB -c "UPDATE compound SET cansmi = mol_to_smiles(mol)"
psql -d $DB -c "UPDATE compound SET mf = mol_formula(mol)"
#
### Add FPs:
psql -d $DB -c "ALTER TABLE compound ADD COLUMN fp BFP"
psql -d $DB -c "UPDATE compound SET fp = rdkit_fp(mol)"
psql -d $DB -c "CREATE INDEX fps_fp_idx ON compound USING gist(fp)"
#
