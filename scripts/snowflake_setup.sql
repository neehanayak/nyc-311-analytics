-- =============================================================================
-- NYC 311 Analytics — Snowflake environment setup
-- Run this once as ACCOUNTADMIN before loading data or running dbt.
-- Every statement uses IF NOT EXISTS so the script is safe to re-run.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Warehouse
-- COMPUTE_WH is the default warehouse tied to this project.
-- X-SMALL is sufficient for CSV loading and dbt development.
-- Auto-suspend at 60 seconds stops credit consumption when idle.
-- Auto-resume lets the connector wake the warehouse transparently.
-- -----------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND   = 60
    AUTO_RESUME    = TRUE
    COMMENT        = 'Primary warehouse for NYC 311 data loading and dbt';

USE WAREHOUSE COMPUTE_WH;


-- -----------------------------------------------------------------------------
-- 2. Database
-- NYC_311_DB holds every layer of the project (raw, staging, marts).
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS NYC_311_DB
    COMMENT = 'NYC 311 service request analytics — all layers';

USE DATABASE NYC_311_DB;


-- -----------------------------------------------------------------------------
-- 3. Schema
-- RAW is the landing zone for data loaded directly from CSV.
-- dbt staging models read from here and write to their own schemas.
-- -----------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS NYC_311_DB.RAW
    COMMENT = 'Raw layer — data as-landed from the NYC 311 CSV ingestion script';

USE SCHEMA NYC_311_DB.RAW;


-- -----------------------------------------------------------------------------
-- 4. Raw staging table
-- All columns are STRING intentionally.
-- The NYC Open Data CSV contains inconsistent date formats, mixed-case
-- borough names, and nullable numeric fields that arrive as empty strings.
-- Storing everything as STRING avoids load-time casting failures and keeps
-- this table a faithful mirror of the source file.
-- Type casting, null handling, and deduplication happen in dbt staging models.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS NYC_311_DB.RAW.stg_311_raw (
    unique_key      STRING  COMMENT 'Unique identifier for each service request',
    created_date    STRING  COMMENT 'Date/time the SR was submitted (cast to TIMESTAMP in dbt)',
    closed_date     STRING  COMMENT 'Date/time the SR was closed — nullable (cast in dbt)',
    agency          STRING  COMMENT 'Acronym of the responding city agency (e.g. NYPD, DEP)',
    agency_name     STRING  COMMENT 'Full name of the responding agency',
    complaint_type  STRING  COMMENT 'Top-level category of the complaint',
    descriptor      STRING  COMMENT 'Sub-category or detail within the complaint type',
    location_type   STRING  COMMENT 'Type of location where the incident occurred',
    incident_zip    STRING  COMMENT 'ZIP code kept as STRING to preserve any leading zeros',
    city            STRING  COMMENT 'City as reported by the submitter',
    borough         STRING  COMMENT 'NYC borough (standardised to uppercase in dbt)',
    latitude        STRING  COMMENT 'WGS-84 latitude — cast to FLOAT in dbt staging',
    longitude       STRING  COMMENT 'WGS-84 longitude — cast to FLOAT in dbt staging',
    status          STRING  COMMENT 'Current status of the service request'
)
COMMENT = 'Raw 311 service requests loaded from CSV — do not query directly, use dbt models';

SELECT COUNT(*) FROM NYC_311_DB.RAW."stg_311_raw";





