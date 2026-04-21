/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    
    -- Calendar
    TRUNCATE TABLE bronze.calendar;
    PRINT('>>> Uploading Calendar');
    BULK INSERT bronze.calendar
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Calendar.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> Calendar: Done');

    -- Category
    TRUNCATE TABLE bronze.category;
    PRINT('>>> Uploading category');
    BULK INSERT bronze.category
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Product_Categories.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> category: Done');

    -- Subcategory
    TRUNCATE TABLE bronze.subcategory;
    PRINT('>>> Uploading subcategory');
    BULK INSERT bronze.subcategory
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Product_Subcategories.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> subcategory: Done');
/*
	-- Products
	TRUNCATE TABLE bronze.products;
	PRINT('>>> Uploading products');
	BULK INSERT bronze.products
	FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Products_Clean.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	PRINT('>>> products: Done');
*/

    -- Customers
    TRUNCATE TABLE bronze.customers;
    PRINT('>>> Uploading customers');
    BULK INSERT bronze.customers
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Customers.csv'
    WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
    PRINT('>>> customers: Done');

    -- Sales Territories
    TRUNCATE TABLE bronze.sales_territories;
    PRINT('>>> Uploading sales_territories');
    BULK INSERT bronze.sales_territories
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Territories.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> sales_territories: Done');

    -- Returns
    TRUNCATE TABLE bronze.returns;
    PRINT('>>> Uploading returns');
    BULK INSERT bronze.returns
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Returns.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> returns: Done');

    -- Sales 2015
    TRUNCATE TABLE bronze.sales2015;
    PRINT('>>> Uploading sales2015');
    BULK INSERT bronze.sales2015
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Sales_2015.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> sales2015: Done');

    -- Sales 2016
    TRUNCATE TABLE bronze.sales2016;
    PRINT('>>> Uploading sales2016');
    BULK INSERT bronze.sales2016
    FROM 'C:\Users\original\Desktop\Dataset\AdventureWorks+CSV+Files\AdventureWorks_Sales_2016.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    PRINT('>>> sales2016: Done');

    PRINT('========================================');
    PRINT('Bronze Layer Loaded Successfully!');
    PRINT('========================================');

END;
GO

exec bronze.load_bronze