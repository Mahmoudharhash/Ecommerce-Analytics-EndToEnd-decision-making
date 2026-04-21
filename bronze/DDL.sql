/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Calendar
IF OBJECT_ID('bronze.calendar', 'U') IS NOT NULL
    DROP TABLE bronze.calendar;
GO

CREATE TABLE bronze.calendar (
    history_date DATE
);
GO

-- Category
IF OBJECT_ID('bronze.category', 'U') IS NOT NULL
    DROP TABLE bronze.category;
GO

CREATE TABLE bronze.category (
    category_key INT,
    category_name NVARCHAR(50)
);
GO

-- Subcategory
IF OBJECT_ID('bronze.subcategory', 'U') IS NOT NULL
    DROP TABLE bronze.subcategory;
GO

CREATE TABLE bronze.subcategory (
    subcategory_key INT,
    subcategory_name NVARCHAR(50),
    category_key INT
);
GO
/*
-- Products
IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
    DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
    product_key INT,
    subcategory_key INT,
    product_sku NVARCHAR(50),
    product_name NVARCHAR(100),
    model_name NVARCHAR(100),
    product_description NVARCHAR(500),
    product_color NVARCHAR(50),
    product_size NVARCHAR(50),
    product_style NVARCHAR(50),
    product_cost NVARCHAR(50),
    product_price NVARCHAR(50)
);
GO
*/
-- Customers
IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers (
    customer_key INT,
    prefix NVARCHAR(50),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    birthdate DATE,
    marital_status NVARCHAR(50),
    gender NVARCHAR(50),
    email_address NVARCHAR(50),
    annual_income NVARCHAR(50),
    total_children INT,
    education_level NVARCHAR(50),
    occupation NVARCHAR(50),
    home_owner NVARCHAR(50)
);
GO

-- Sales Territories
IF OBJECT_ID('bronze.sales_territories', 'U') IS NOT NULL
    DROP TABLE bronze.sales_territories;
GO

CREATE TABLE bronze.sales_territories (
    sales_territory_key INT,
    region NVARCHAR(50),
    country NVARCHAR(50),
    continent NVARCHAR(50)
);
GO

-- Returns 
IF OBJECT_ID('bronze.returns', 'U') IS NOT NULL
    DROP TABLE bronze.returns;
GO

CREATE TABLE bronze.returns (
    return_date DATE,
    territory_key INT,
    product_key INT,
    return_quantity INT
);
GO

-- Sales 2015
IF OBJECT_ID('bronze.sales2015', 'U') IS NOT NULL
    DROP TABLE bronze.sales2015;
GO

CREATE TABLE bronze.sales2015 (
    order_date DATE,
    stock_date DATE,
    order_number NVARCHAR(50),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);
GO

-- Sales 2016 
IF OBJECT_ID('bronze.sales2016', 'U') IS NOT NULL
    DROP TABLE bronze.sales2016;
GO

CREATE TABLE bronze.sales2016 (
    order_date DATE,
    stock_date DATE,
    order_number NVARCHAR(50),
    product_key INT,
    customer_key INT,
    territory_key INT,
    order_line_item INT,
    order_quantity INT
);
GO