/*
=================================================================================
Quality Checks
=================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
=================================================================================
Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
=================================================================================
*/


/*
QUALITY CHECKS: bronze.crm_cust_info
*/

SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


SELECT
    cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);


SELECT
    cst_firstname,
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);


SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info;


SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info;


SELECT
    cst_id,
    cst_create_date
FROM bronze.crm_cust_info
WHERE cst_create_date IS NULL;



/*
QUALITY CHECKS: bronze.crm_prd_info
*/

SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


SELECT
    prd_key
FROM bronze.crm_prd_info
WHERE prd_key != TRIM(prd_key);


SELECT
    prd_id,
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm IS NULL
   OR TRIM(prd_nm) = '';


SELECT
    prd_id,
    pra_cost
FROM bronze.crm_prd_info
WHERE pra_cost IS NULL
   OR pra_cost < 0;


SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;


SELECT
    prd_id,
    pra_start_dt
FROM bronze.crm_prd_info
WHERE pra_start_dt IS NULL;


SELECT
    prd_id,
    prd_key,
    pra_start_dt,
    LEAD(pra_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY pra_start_dt
    ) AS next_start_date
FROM bronze.crm_prd_info
ORDER BY
    prd_key,
    pra_start_dt;


SELECT
    prd_id,
    prd_key
FROM bronze.crm_prd_info
WHERE prd_key IS NULL
   OR LEN(prd_key) < 7;



/*
QUALITY CHECKS: bronze.crm_sales_details
*/

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL
   OR sls_prd_key IS NULL
   OR sls_cust_id IS NULL;


SELECT
    sls_ord_num,
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_order_dt = 0
   OR LEN(CAST(sls_order_dt AS VARCHAR(20))) != 8
   OR TRY_CONVERT(
        DATE,
        CAST(sls_order_dt AS VARCHAR(20)),
        112
      ) IS NULL;


SELECT
    sls_ord_num,
    sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR sls_ship_dt = 0
   OR LEN(CAST(sls_ship_dt AS VARCHAR(20))) != 8
   OR TRY_CONVERT(
        DATE,
        CAST(sls_ship_dt AS VARCHAR(20)),
        112
      ) IS NULL;


SELECT
    sls_ord_num,
    s1s_due_dt
FROM bronze.crm_sales_details
WHERE s1s_due_dt IS NULL
   OR s1s_due_dt = 0
   OR LEN(CAST(s1s_due_dt AS VARCHAR(20))) != 8
   OR TRY_CONVERT(
        DATE,
        CAST(s1s_due_dt AS VARCHAR(20)),
        112
      ) IS NULL;


SELECT
    sls_ord_num,
    s1s_sales,
    sls_quantity,
    sls_price,
    sls_quantity * ABS(sls_price) AS calculated_sales
FROM bronze.crm_sales_details
WHERE s1s_sales IS NULL
   OR s1s_sales <= 0
   OR s1s_sales != sls_quantity * ABS(sls_price);


SELECT
    sls_ord_num,
    sls_quantity
FROM bronze.crm_sales_details
WHERE sls_quantity IS NULL
   OR sls_quantity <= 0;


SELECT
    sls_ord_num,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_price IS NULL
   OR sls_price <= 0;


SELECT
    sls_ord_num,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_price < 0;



/*
QUALITY CHECKS: bronze.erp_loc_a101
*/

SELECT
    cid
FROM bronze.erp_loc_a101
WHERE cid IS NULL;


SELECT
    cid,
    COUNT(*) AS duplicate_count
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;


SELECT
    cid
FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%';


SELECT DISTINCT
    cntry
FROM bronze.erp_loc_a101;


SELECT
    cntry
FROM bronze.erp_loc_a101
WHERE cntry != TRIM(cntry);


SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';



/*
QUALITY CHECKS: bronze.erp_px_cat_g1v2
*/

SELECT
    id,
    COUNT(*) AS duplicate_count
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


SELECT
    id,
    cat
FROM bronze.erp_px_cat_g1v2
WHERE cat IS NULL
   OR TRIM(cat) = '';


SELECT
    id,
    subcat
FROM bronze.erp_px_cat_g1v2
WHERE subcat IS NULL
   OR TRIM(subcat) = '';


SELECT
    id,
    maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance IS NULL
   OR TRIM(maintenance) = '';


SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2;


SELECT DISTINCT
    subcat
FROM bronze.erp_px_cat_g1v2;


SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2;



