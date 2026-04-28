USE Warehouse;

-- 1. Check invalid order dates
SELECT sls_ord_num, sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8;

-- 2. Check invalid ship dates
SELECT sls_ord_num, sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8;

-- 3. Check invalid due dates
SELECT sls_ord_num, sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8;

-- 4. Check sales amount anomalies
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL 
   OR sls_sales <= 0
   OR sls_sales != sls_quantity * ABS(sls_price);

-- 5. Check invalid price values
SELECT sls_ord_num, sls_price, sls_sales, sls_quantity
FROM bronze.crm_sales_details
WHERE sls_price IS NULL OR sls_price <= 0;

-- Tranfering after clean data

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN CASE 
                WHEN sls_quantity = 0 THEN NULL
                ELSE sls_sales / sls_quantity
             END
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;


-- TEST

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LENGTH(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
