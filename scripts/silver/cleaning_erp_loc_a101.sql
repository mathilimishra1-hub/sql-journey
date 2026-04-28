USE Warehouse;

-- 1️⃣ Check CIDs with hyphens
SELECT cid
FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%';
-- AW-00011000,"-" is unnecessary

-- 2️⃣ Check for missing or blank country codes
SELECT cid, cntry
FROM bronze.erp_loc_a101
WHERE cntry IS NULL OR TRIM(cntry) = '';

-- 3️⃣ Check for country codes needing normalization
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
WHERE TRIM(cntry) IN ('DE', 'US', 'USA');


TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;


-- TEST

SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;
