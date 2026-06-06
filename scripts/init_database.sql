/*
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWareHouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse')
BEGIN
    ALTER DATABASE DataWareHouse
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWareHouse;
END;
GO

-- Create the 'DataWareHouse' database
CREATE DATABASE DataWareHouse;
GO

USE DataWareHouse;
GO

-- Create Schemas
CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
