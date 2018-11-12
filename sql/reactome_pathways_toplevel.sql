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
SELECT DISTINCT
	id
FROM
	reactome.reactomepathwaysrelation
WHERE
	id NOT IN ( SELECT DISTINCT id_subclass FROM reactome.reactomepathwaysrelation )
ORDER BY
	id
	;
-- 
SELECT
	reactomepathways.id,
	reactomepathways.name AS "pathway_name"
FROM
	reactome.reactomepathways
WHERE 
	id NOT IN ( SELECT DISTINCT id_subclass FROM reactome.reactomepathwaysrelation )
	AND reactomepathways.organism = 'Homo sapiens'
ORDER BY
	reactomepathways.name
	;
--
