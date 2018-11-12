--
SELECT DISTINCT
	c.pubchem_sid AS "SID",
	c.pubchem_cid AS "CID",
	u.chembl_mol_id
FROM
	compound c,
	unichem_chembl2pccid u
WHERE
	c.pubchem_cid::VARCHAR(16) = u.pubchem_cid
ORDER BY
	c.pubchem_sid,
	c.pubchem_cid
	;
--
