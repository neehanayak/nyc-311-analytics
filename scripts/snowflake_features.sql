-- =============================================================================
-- Snowflake-Native Features — NYC 311 Analytics
-- Reference examples for features that have no equivalent in standard SQL.
-- Run these manually in a Snowflake worksheet; they are not part of dbt.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Zero-Copy Cloning
--
-- Creates an instant copy of the table with NO additional storage cost at the
-- moment of cloning. Snowflake achieves this by sharing the same underlying
-- micro-partitions between the source and clone — only future writes diverge
-- and consume new storage.
--
-- When to use it:
--   - Create an isolated dev or QA copy of a production table without doubling
--     storage costs or waiting for a full data copy.
--   - Test a destructive dbt run (overwrite=True) against a clone before
--     touching the real table.
--   - Give an analyst a sandbox snapshot of a large table they can freely
--     modify without affecting the pipeline.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE NYC_311_DB.RAW.stg_311_dev
    CLONE NYC_311_DB.RAW."stg_311_raw";


-- -----------------------------------------------------------------------------
-- 2. Time Travel — Query a Table as It Was 1 Day Ago
--
-- Snowflake retains historical versions of every table for up to 90 days
-- (default 1 day on Standard edition). The AT clause lets you query any
-- past state without restoring anything.
--
-- OFFSET => -N means "go back N seconds from now". Must stay within retention.
--
-- When to use it:
--   - Validate a transformation by comparing today's row count to yesterday's.
--   - Investigate whether a bug existed in the data before a pipeline change.
--   - Recover specific rows that were overwritten by an accidental dbt run.
-- -----------------------------------------------------------------------------
SELECT *
FROM NYC_311_DB.RAW."stg_311_raw"
    AT(OFFSET => -300)  -- 300 seconds (5 minutes); increase up to retention period
LIMIT 100;


-- -----------------------------------------------------------------------------
-- 3. Undrop a Table
--
-- If a table is dropped (accidentally or otherwise), Snowflake keeps it in a
-- hidden Fail-Safe area during the Time Travel retention window. UNDROP TABLE
-- restores it instantly with no data loss.
--
-- When to use it:
--   - A developer runs DROP TABLE on the wrong environment.
--   - An overwrite in dbt or the ingestion script removes a table you still
--     need and you want to roll back immediately without re-loading from CSV.
--
-- Note: UNDROP only works within the Time Travel retention period. After that
-- the table is gone permanently.
-- -----------------------------------------------------------------------------
UNDROP TABLE NYC_311_DB.RAW."stg_311_raw";


-- -----------------------------------------------------------------------------
-- 4. Query a Table at a Specific Past Timestamp
--
-- Instead of a relative offset, you can pin the query to an exact point in
-- time using a TIMESTAMP. Useful when you know precisely when a bad load ran
-- or when a stakeholder asks "what did the data look like on date X?"
--
-- Replace the timestamp below with the specific moment you want to inspect.
--
-- When to use it:
--   - An analyst reports that a dashboard showed wrong numbers on a specific
--     date — reproduce exactly what the table contained at that moment.
--   - Audit a regulatory snapshot: prove what data existed at month-end close.
--   - Compare the table before and after a data quality fix was deployed.
-- -----------------------------------------------------------------------------
SELECT *
FROM NYC_311_DB.RAW."stg_311_raw"
    AT(TIMESTAMP => DATEADD(MINUTES, -5, CURRENT_TIMESTAMP())::TIMESTAMP_LTZ)
LIMIT 100;
