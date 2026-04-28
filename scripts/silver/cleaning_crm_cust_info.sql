use Warehouse;

Select cst_id,Count(*) from bronze.crm_cust_info
group by cst_id
having count(*)>1 or cst_id is Null;

-- Found Dulipcate Primary key---
select * from Bronze.crm_cust_info where cst_id=29449;

-- will pick the latest details using window functions
select
*
from(
select
*,
row_number() over (Partition By cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last =1;



-- Checking for naming convection

select cst_firstname
from bronze.crm_cust_info
where cst_firstname !=TRIM(cst_firstname);


select cst_lastname
from bronze.crm_cust_info
where cst_firstname !=TRIM(cst_lastname);

-- merging in main transformation logic 

select
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
from(
select
*,
row_number() over (Partition By cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last =1;

-- encding the low cardinal discrete value
select
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE WHEN  Upper(Trim(cst_marital_status))='S' Then 'Single'
	WHEN Upper(Trim(cst_marital_status))='M' Then "Married"
    Else 'n/a'
End
cst_marital_status,
CASE WHEN  Upper(Trim(cst_gndr))='F' Then 'Female'
	WHEN Upper(Trim(cst_gndr))='M' Then "Male"
    Else 'n/a'
End
cst_gndr,
cst_create_date
from(
select
*,
row_number() over (Partition By cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
)t where flag_last =1;


USE Warehouse;

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    dwh_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date,
    CURRENT_TIMESTAMP AS dwh_create_date
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;


-- Checking the trnasfer
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;
