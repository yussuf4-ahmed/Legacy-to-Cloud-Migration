-- Create the main database and schemas
CREATE DATABASE IF NOT EXISTS PULSECORE_ANALYTICS_DEV;

-- This is where Python will dump the raw data
CREATE SCHEMA IF NOT EXISTS BRONZE;

-- This is where dbt will put the cleaned data later
CREATE SCHEMA IF NOT EXISTS SILVER;

-- This is where dbt will put the cleaned data later
CREATE SCHEMA IF NOT EXISTS GOLD;

-- Create a Virtual Warehouse (the "engine")
CREATE WAREHOUSE IF NOT EXISTS migration_wh 
WITH WAREHOUSE_SIZE = 'XSMALL' 
AUTO_SUSPEND = 60 
INITIALLY_SUSPENDED = TRUE;
