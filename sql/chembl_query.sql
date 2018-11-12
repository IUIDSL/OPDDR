-- 
SELECT c.ncgc_id, c.pubchem_cid FROM compound c WHERE c.pubchem_cid = 12597 ;
SELECT c.ncgc_id, c.pubchem_cid FROM compound c WHERE c.pubchem_cid::VARCHAR(16) = '12597' ;
-- 
-- 
-- 
SELECT
	c.ncgc_id,
	c.pubchem_cid,
	p.pubchem_iupac_inchikey,
	u.chembl_id,
	a.reference,
	a.assay_chemblid,
	a.assay_type,
	a.target_chemblid,
	a.target_name,
	a.parent_cmpd_chemblid,
	a.bioactivity_type,
	a.units,
	a.value
FROM
	compound c,
	pubchem_cid2inchi p,
	unichem_inchi2chembl u,
	chembl_activity a
WHERE
	c.pubchem_cid = 12597
	AND c.pubchem_cid::VARCHAR(16) = p.pubchem_compound_cid
	AND p.pubchem_iupac_inchikey = u.inchikey
	AND u.chembl_id = a.chemblid_query
	AND a.units = 'nM'
	;
--
--
