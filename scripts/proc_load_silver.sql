/*
=========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=========================================================================

Script Purpose:
This stored procedure performs the ETL (Extract,]Transform, Load) process to 
populate the 'silver' schema tables from the 'be aze' schema.
Actions Performed:
- Truncates Silver tables.
- Inserts transformed and cleansed data from Bronze into Silver tables.
=========================================================================

Parameters:
None.
This stored procedure does not accept any parameters or return any values.
==========================================================================

USAGE EXAMPLE
EXEC silver.load_silver
=========================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    -- ==========================================
    -- DECLARE VARIABLES
    -- ==========================================

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @RowsLoaded INT;

    BEGIN TRY

        SET NOCOUNT ON;

        PRINT '==========================================';
        PRINT '       STARTING SILVER LAYER LOAD';
        PRINT '==========================================';


        -- ==========================================
        -- CRM TABLES
        -- ==========================================

        PRINT '------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------';


        -- ==========================================
        -- 1. CRM CUSTOMER INFO
        -- ==========================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )

        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,

            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S'
                    THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M'
                    THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F'
                    THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M'
                    THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date

        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last

            FROM bronze.crm_cust_info

        ) AS t

        WHERE t.flag_last = 1;

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into silver.crm_cust_info';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- ==========================================
        -- 2. CRM PRODUCT INFO
        -- ==========================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            pra_cost,
            prd_line,
            pra_start_dt,
            prd_end_dt
        )

        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(pra_cost, 0) AS pra_cost,

            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,

            CAST(pra_start_dt AS DATE) AS prd_start_dt,

            CAST(
                LEAD(pra_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY pra_start_dt
                ) - 1 AS DATE
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into silver.crm_prd_info';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- ==========================================
        -- CHECK PRODUCT DATE LOGIC
        -- ==========================================

        SELECT
            prd_id,
            prd_key,
            prd_nm,
            pra_start_dt,
            prd_end_dt,
            LEAD(pra_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY pra_start_dt
            ) AS prd_end_dt_test

        FROM bronze.crm_prd_info

        WHERE prd_key IN (
            'AC-HE-HL-U509-R',
            'AC-HE-HL-U509'
        );


        -- ==========================================
        -- 3. CRM SALES DETAILS
        -- ==========================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            s1s_due_dt,
            s1s_sales,
            sls_quantity,
            sls_price
        )

        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8
                    THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8
                    THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            CASE
                WHEN s1s_due_dt = 0 OR LEN(s1s_due_dt) != 8
                    THEN NULL
                ELSE CAST(CAST(s1s_due_dt AS VARCHAR) AS DATE)
            END AS s1s_due_dt,

            CASE
                WHEN s1s_sales IS NULL
                     OR s1s_sales <= 0
                     OR s1s_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE s1s_sales
            END AS s1s_sales,

            sls_quantity,

            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                    THEN s1s_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into silver.crm_sales_details';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';

        PRINT 'CRM TABLES LOADED SUCCESSFULLY';


        -- ==========================================
        -- ERP TABLES
        -- ==========================================

        PRINT '------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------';


        -- ==========================================
        -- 4. ERP LOCATION
        -- ==========================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_loc_a101';

        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )

        SELECT
            REPLACE(cid, '-', '') AS cid,

            CASE
                WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) = 'DE'
                    THEN 'Germany'

                WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('US', 'USA')
                    THEN 'United States'

                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = ''
                     OR cntry IS NULL
                    THEN 'n/a'

                ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))

            END AS cntry

        FROM bronze.erp_loc_a101;

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into silver.erp_loc_a101';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- ==========================================
        -- 5. ERP PRODUCT CATEGORY
        -- ==========================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )

        SELECT
            id,
            cat,
            subcat,
            maintenance

        FROM bronze.erp_px_cat_g1v2;

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into silver.erp_px_cat_g1v2';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        PRINT 'ERP TABLES LOADED SUCCESSFULLY';


        -- ==========================================
        -- COMPLETION
        -- ==========================================

        PRINT '==========================================';
        PRINT '       SILVER LAYER LOAD COMPLETED';
        PRINT '==========================================';


    END TRY

    BEGIN CATCH

        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT '====================================================';

        THROW;

    END CATCH

END;

EXEC silver.load_silver;
 
