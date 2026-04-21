/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
--calendar
	TRUNCATE TABLE silver.calendar;
	PRINT('uploading Calendar table....');
	INSERT INTO silver.calendar (
		[history_date]
	)
	SELECT [history_date]
	FROM [SalesService].[bronze].[calendar];
	PRINT('Calendar table is DONE');

--category
	TRUNCATE TABLE silver.category;
	PRINT('uploading Category table....');
	INSERT INTO silver.category (
		[category_key]
	   ,[category_name]
	)
	SELECT [category_key]
		  ,TRIM([category_name]) as category_name
	  FROM [SalesService].[bronze].[category]
	PRINT('category table is DONE');

--customers
	TRUNCATE TABLE silver.customers;
	PRINT('uploading customers table....');
	INSERT INTO silver.customers (
		 [customer_key]
		,[prefix]
		,[first_name]
		,[last_name]
		,[birthdate]
		,[marital_status]
		,[gender]
		,[email_address]
		,[annual_income]
		,[total_children]
		,[education_level]
		,[occupation]
		,[home_owner]
	)

	select
		customer_key,
		case 
			when prefix is null then 'n/a'
			else trim(prefix)
		end as prefix,
		upper(left(trim(first_name),1)) + lower(substring(trim(first_name),2,LEN(first_name))) as first_name,
		upper(left(trim(last_name),1)) + lower(substring(trim(last_name),2,LEN(last_name))) as last_name,
		birthdate,
		trim(marital_status) as marital_status,
		trim(gender) as gender,
		email_address,
		CAST(
			 REPLACE(REPLACE(annual_income, '$', ''), '"', '')
		AS INT) as annual_income,
		total_children,
		education_level,
		occupation,
		case
			when home_owner = 'Y' then 'Yes'
			when home_owner = 'N' then 'No'
			else 'n/a'
		end as home_owner
	from [SalesService].[bronze].[customers];
	PRINT('customers table is DONE');

--products
	TRUNCATE TABLE silver.Products;
	PRINT('uploading Products table....');
	INSERT INTO silver.Products (
		product_key ,
		subcategory_key ,
		product_sku ,
		product_name ,
		model_name ,
		product_description ,
		product_color ,
		product_size ,
		product_style ,
		product_cost ,
		product_price 
	)
	SELECT [ProductKey]
		  ,[ProductSubcategoryKey]
		  ,[ProductSKU]
		  ,[ProductName]
		  ,[ModelName]
		  ,[ProductDescription]
		  ,[ProductColor]
		  ,[ProductSize]
		  ,[ProductStyle]
		  ,[ProductCost]
		  ,[ProductPrice]
	FROM [SalesService].[bronze].[Products]
	PRINT('Products table is DONE');

--sales_territories
	TRUNCATE TABLE silver.sales_territories;
	PRINT('uploading sales_territories table....');
	INSERT INTO silver.sales_territories (
		   [sales_territory_key]
		  ,[region]
		  ,[country]
		  ,[continent]
	)
	SELECT [sales_territory_key]
		  ,[region]
		  ,[country]
		  ,[continent]
	FROM [SalesService].[bronze].[sales_territories]
	PRINT('sales_territories table is DONE');

--subcategory
	TRUNCATE TABLE silver.subcategory;
	PRINT('uploading subcategory table....');
	INSERT INTO silver.subcategory (
	 		 [subcategory_key]
			,[subcategory_name]
			,[category_key]
	)
	SELECT [subcategory_key]
		  ,[subcategory_name]
		  ,[category_key]
	FROM [SalesService].[bronze].[subcategory]
	PRINT('Subcategory table is DONE');

--Returns
	TRUNCATE TABLE silver.returns;
	PRINT('uploading returns table....');
	INSERT INTO silver.returns (
			[return_date]
			,[territory_key]
			,[product_key]
			,[return_quantity]
	)
	SELECT [return_date]
		  ,[territory_key]
		  ,[product_key]
		  ,[return_quantity]
	FROM [SalesService].[bronze].[returns]
	PRINT('Returns table is DONE');

--sales2015
	TRUNCATE TABLE silver.sales2015;
	PRINT('uploading sales2015 table....');
	INSERT INTO silver.sales2015 (
			[order_date]
			,[stock_date]
			,[order_number]
			,[product_key]
			,[customer_key]
			,[territory_key]
			,[order_line_item]
			,[order_quantity]
	)
	SELECT [order_date]
		  ,[stock_date]
		  ,[order_number]
		  ,[product_key]
		  ,[customer_key]
		  ,[territory_key]
		  ,[order_line_item]
		  ,[order_quantity]
	FROM [SalesService].[bronze].[sales2015]
	PRINT('Sales2015 DONE');

--sales2016
	TRUNCATE TABLE silver.sales2016;
	PRINT('uploading sales2016 table....');
	INSERT INTO silver.sales2016 (
			[order_date]
			,[stock_date]
			,[order_number]
			,[product_key]
			,[customer_key]
			,[territory_key]
			,[order_line_item]
			,[order_quantity]
	)
	SELECT [order_date]
		  ,[stock_date]
		  ,[order_number]
		  ,[product_key]
		  ,[customer_key]
		  ,[territory_key]
		  ,[order_line_item]
		  ,[order_quantity]
	FROM [SalesService].[bronze].[sales2016]
	PRINT('Sales2016 DONE');
END