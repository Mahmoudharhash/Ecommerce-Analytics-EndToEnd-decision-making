/*
===============================================================================
DDL Script: Create silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Calendar
IF OBJECT_ID('silver.calendar', 'U') IS NOT NULL
    DROP TABLE silver.calendar;
GO

CREATE TABLE silver.calendar (
    history_date DATE
);
GO

-- Category
IF OBJECT_ID('silver.category', 'U') IS NOT NULL
    DROP TABLE silver.category;
GO

CREATE TABLE silver.category (
    category_key INT,
    category_name NVARCHAR(50)
);
GO

-- Subcategory
IF OBJECT_ID('silver.subcategory', 'U') IS NOT NULL
    DROP TABLE silver.subcategory;
GO

CREATE TABLE silver.subcategory (
    subcategory_key INT,
    subcategory_name NVARCHAR(50),
    category_key INT
);
GO

-- Products
IF OBJECT_ID('silver.products', 'U') IS NOT NULL
    DROP TABLE silver.products;
GO

CREATE TABLE silver.products (
    product_key INT,
    subcategory_key INT,
    product_sku NVARCHAR(50),
    product_name NVARCHAR(100),
    model_name NVARCHAR(100),
    product_description NVARCHAR(500),
    product_color NVARCHAR(50),
    product_size NVARCHAR(50),
    product_style NVARCHAR(50),
    product_cost float,
    product_price float
);
GO

-- Customers
IF OBJECT_ID('silver.customers', 'U') IS NOT NULL
    DROP TABLE silver.customers;
GO

CREATE TABLE silver.customers (
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
IF OBJECT_ID('silver.sales_territories', 'U') IS NOT NULL
    DROP TABLE silver.sales_territories;
GO

CREATE TABLE silver.sales_territories (
    sales_territory_key INT,
    region NVARCHAR(50),
    country NVARCHAR(50),
    continent NVARCHAR(50)
);
GO

-- Returns 
IF OBJECT_ID('silver.returns', 'U') IS NOT NULL
    DROP TABLE silver.returns;
GO

CREATE TABLE silver.returns (
    return_date DATE,
    territory_key INT,
    product_key INT,
    return_quantity INT
);
GO

-- Sales 2015
IF OBJECT_ID('silver.sales2015', 'U') IS NOT NULL
    DROP TABLE silver.sales2015;
GO

CREATE TABLE silver.sales2015 (
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
IF OBJECT_ID('silver.sales2016', 'U') IS NOT NULL
    DROP TABLE silver.sales2016;
GO

CREATE TABLE silver.sales2016 (
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