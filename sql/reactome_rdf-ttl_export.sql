--reactomepathwaysrelation
-- column_name |     data_type     
---------------+-------------------
-- id          | character varying
-- id_subclass | character varying
--
--reactomepathways
-- column_name |     data_type     
---------------+-------------------
-- id          | character varying
-- name        | character varying
-- organism    | character varying
--
--reactome2uniprot
-- column_name |     data_type     
---------------+-------------------
-- uniprot     | character varying
-- reactome_id | character varying
-- 
SELECT
	'reac:'||rp.id ||' rdfs:linkedTo '||'unip:'||u.uniprot||' .'
FROM
	reactome.reactomepathways rp,
	reactome.reactome2uniprot u
WHERE
	u.reactome_id = rp.id
	AND rp.organism = 'Homo sapiens'
LIMIT 100
	;
--
