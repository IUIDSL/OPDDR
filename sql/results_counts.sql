-- 
SELECT COUNT(*) AS "result_count" FROM results r ;
SELECT COUNT(DISTINCT ncgc_id) AS "substance_count" FROM results r ;
SELECT COUNT(DISTINCT oidd_assay) AS "assay_count" FROM results r ;
-- 
SELECT
	outcome,
	COUNT(ncgc_id) AS "result_count"
FROM
	results r
GROUP BY
	outcome
	;
--
SELECT
	result_type,
	COUNT(ncgc_id) AS "result_count"
FROM
	results r
GROUP BY
	result_type
	;
--
SELECT
	test_type,
	COUNT(ncgc_id) AS "result_count"
FROM
	results r
GROUP BY
	test_type
	;
--
SELECT
	result_uom,
	COUNT(ncgc_id) AS "result_count"
FROM
	results r
GROUP BY
	result_uom
	;
--
