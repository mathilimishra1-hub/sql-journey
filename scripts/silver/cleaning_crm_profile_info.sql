Use Warehouse;


-- cleaning crm_prof_info
select * from bronze.crm_prd_info;

-- lets find connections
select * from bronze.erp_cust_az12;
-- no meduim to connect the crm_prf_info to erm_cust_az12
select * from bronze.erp_loc_a101;
-- no connection
select * from bronze.erp_px_cat_g1v2;
-- connection can be derived using substring
select * from bronze.crm_sales_details;
-- connection can be derived using substring


select 
prd_id,
prd_key,
Replace(Substring(prd_key,1,5),'-','_') AS cat_id,
Substring(prd_key,7,LENGTH(prd_key)) as prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
From bronze.crm_prd_info;

-- checking for inconsistent naming

select prd_nm
from bronze.crm_prd_info
where  prd_nm!=TRIM(prd_nm);
-- no problem

select prd_cost
from bronze.crm_prd_info
where  prd_cost<0 or prd_cost Is Null;
-- no problem

select 
prd_id,
prd_key,
Replace(Substring(prd_key,1,5),'-','_') AS cat_id,
Substring(prd_key,7,LENGTH(prd_key)) as prd_key,
prd_nm,
IFNULL(prd_cost,0) as Prd_cost,
Case When  upper(Trim(Prd_line))='M' Then 'Mountain'
	When  upper(Trim(Prd_line))='R' Then 'Road'
	When  upper(Trim(Prd_line))='S' Then 'Other Sales'
    When  upper(Trim(Prd_line))='T' Then 'Touring'
    Else 'n/a'
END as prd_line,
prd_start_dt,
prd_end_dt
From bronze.crm_prd_info;


-- Cleaning the dates
select 
prd_id,
prd_key,
Replace(Substring(prd_key,1,5),'-','_') AS cat_id,
Substring(prd_key,7,LENGTH(prd_key)) as prd_key,
prd_nm,
IFNULL(prd_cost,0) as Prd_cost,
Case When  upper(Trim(Prd_line))='M' Then 'Mountain'
	When  upper(Trim(Prd_line))='R' Then 'Road'
	When  upper(Trim(Prd_line))='S' Then 'Other Sales'
    When  upper(Trim(Prd_line))='T' Then 'Touring'
    Else 'n/a'
END as prd_line,
DATE(prd_start_dt) AS prd_start_dt,
DATE_SUB(
    LEAD(prd_end_dt) OVER (PARTITION BY prd_key ORDER BY Prd_start_dt),
    INTERVAL 1 DAY
) AS prd_end_dt


From bronze.crm_prd_info;

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
select 
prd_id,
Replace(Substring(prd_key,1,5),'-','_') AS cat_id,
Substring(prd_key,7,LENGTH(prd_key)) as prd_key,
prd_nm,
IFNULL(prd_cost,0) as Prd_cost,
Case When  upper(Trim(Prd_line))='M' Then 'Mountain'
	When  upper(Trim(Prd_line))='R' Then 'Road'
	When  upper(Trim(Prd_line))='S' Then 'Other Sales'
    When  upper(Trim(Prd_line))='T' Then 'Touring'
    Else 'n/a'
END as prd_line,
DATE(prd_start_dt) AS prd_start_dt,
DATE_SUB(
    LEAD(prd_end_dt) OVER (PARTITION BY prd_key ORDER BY Prd_start_dt),
    INTERVAL 1 DAY
) AS prd_end_dt


From bronze.crm_prd_info;


-- TEST

SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
 

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
