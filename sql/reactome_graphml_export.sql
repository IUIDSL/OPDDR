-- 
SELECT DISTINCT
	'<node id="'||rp.id||'"><data key="name">'||rp.name||'</data></node>'
FROM
	reactome.reactomepathways rp
WHERE
	rp.organism = 'Homo sapiens'
	;
-- 
SELECT DISTINCT
    '<edge source="'||rpr.id||'" target="'||rpr.id_subclass||'"></edge>'
FROM
	reactome.reactomepathwaysrelation rpr,
	reactome.reactomepathways rp
WHERE
	rpr.id = rp.id
	AND rp.organism = 'Homo sapiens'
	;
-- 
--
