USE Warehouse;

-- 1️⃣ Check CIDs with 'NAS' prefix
SELECT cid
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%'; 

select * from bronze.crm_cust_info where cst_key='AW00011000'; -- so after NAS its cst_key.

-- 2️⃣ Check for birthdates in the future
SELECT cid, bdate
FROM bronze.erp_cust_az12
WHERE bdate > CURDATE();

-- 3️⃣ Check gender values outside Male/Female
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
