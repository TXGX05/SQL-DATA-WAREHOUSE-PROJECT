/*
==========================================================================================
Stored Procedure: Load Bronze Layer (Source -› Bronze)
==========================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' from schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values

USAGE EXAMPLE :
    EXEC bronze.load_bronze;
==========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze

AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
    		@batch_start_time DATETIME,
    		@batch_end_time DATETIME;

    DECLARE @RowsLoaded INT;

    BEGIN TRY
		SET @batch_start_time = GETDATE();
        SET NOCOUNT ON;

        PRINT '==========================================';
        PRINT '       STARTING BRONZE LAYER LOAD';
        PRINT '==========================================';


        -- ==========================================
        -- CRM TABLES
        -- ==========================================

        PRINT '------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------';


        -- 1. CRM CUSTOMER INFO

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/datasets/source_crm/cust_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.crm_cust_info';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- 2. CRM PRODUCT INFO

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/datasets/source_crm/prd_info.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.crm_prd_info';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- 3. CRM SALES DETAILS

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/datasets/source_crm/sales_details.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.crm_sales_details';

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


        -- 4. ERP LOCATION

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/datasets/source_erp/loc_a101.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.erp_loc_a101';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- 5. ERP CUSTOMER

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/datasets/source_erp/cust_az12.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.erp_cust_az12';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';


        -- 6. ERP PRODUCT CATEGORY

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/datasets/source_erp/px_cat_g1v2.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @RowsLoaded = @@ROWCOUNT;

        PRINT '>> Loaded ' + CAST(@RowsLoaded AS VARCHAR(20))
              + ' Rows Into bronze.erp_px_cat_g1v2';

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
              + ' seconds';

        PRINT '>> -------------------';

        PRINT 'ERP TABLES LOADED SUCCESSFULLY';

		SET @batch_end_time = GETDATE();
        
		-- ==========================================
        -- COMPLETION
        -- ==========================================

        PRINT '==========================================';
        PRINT '    BRONZE LAYER LOAD COMPLETED';
        PRINT '- Total Load Duration:' + CAST(DATEDIFF(SECOND,@batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '==========================================';

    END TRY

    BEGIN CATCH

        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT '====================================================';

        THROW;

    END CATCH
 
END;


EXEC bronze.load_bronze; 
