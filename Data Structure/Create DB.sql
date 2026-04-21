/*
===============================================================================
Create Database and schema
===============================================================================
Script Purpose:
    This script creates the Database and 3 Schemas (Bronze - Silver - Gold )
===============================================================================
*/


use master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SalesService')
BEGIN
    ALTER DATABASE SalesService SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SalesService;
END;
GO

-- Create the 'SalesService' database
CREATE DATABASE SalesService;
GO

use SalesService;
GO

Create Schema bronze;
GO

Create Schema silver;
GO

Create Schema gold;
GO
