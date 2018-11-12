-- 
-- Export CSV
-- 
SELECT DISTINCT
	a.target_chemblid,
	'"'||a.target_name||'"',
	'"'||t.targettype||'"'
FROM
	compound c,
	pubchem_cid2inchi p,
	unichem_inchi2chembl u,
	chembl_activity a,
	chembl_target t
WHERE
	c.pubchem_cid::VARCHAR(16) = p.pubchem_compound_cid
	AND p.pubchem_iupac_inchikey = u.inchikey
	AND u.chembl_id = a.chemblid_query
	AND a.units = 'nM'
	AND a.target_chemblid = t.chemblid
ORDER BY
	'"'||t.targettype||'"'
	;
--
--	AND a.value <= 1000
--
--SELECT DISTINCT
--	'chembl_target:'||a.target_chemblid||' a cco:SingleProtein ;',
--	'dcterms:title "'||a.target_name||'" .'
--FROM
--	compound c,
--	pubchem_cid2inchi p,
--	unichem_inchi2chembl u,
--	chembl_activity a,
--	chembl_target t
--WHERE
--	c.pubchem_cid::VARCHAR(16) = p.pubchem_compound_cid
--	AND p.pubchem_iupac_inchikey = u.inchikey
--	AND u.chembl_id = a.chemblid_query
--	AND a.units = 'nM'
--	AND a.target_chemblid = t.chemblid
--	AND t.targettype = 'SINGLE PROTEIN'
--	;
--
