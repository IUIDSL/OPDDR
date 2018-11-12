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
	reactomepathways.id AS "pathway_id",
	reactomepathways.name AS "pathway_name",
	reactome2uniprot.uniprot
FROM
	reactome.reactomepathways,
	reactome.reactome2uniprot
WHERE
	reactome2uniprot.reactome_id = reactomepathways.id
	AND reactomepathways.organism = 'Homo sapiens'
LIMIT 100
	;
--
