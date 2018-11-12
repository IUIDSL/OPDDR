-- 
SELECT
	COUNT(a.pchembl_value) AS "activity_count",
	COUNT(DISTINCT c.ncgc_id) AS "compound_count",
	COUNT(DISTINCT a.assay_chembl_id) AS "assay_count"
FROM
	compound c
JOIN
	cid2chemblid c2c ON c.pubchem_cid::VARCHAR(16) = c2c.cid
JOIN
	chembl_activity a ON c2c.chemblid = a.molecule_chembl_id
WHERE
	a.pchembl_value IS NOT NULL
	;
--
--
-- COUNT(DISTINCT a.target_chemblid) AS "target_count"
