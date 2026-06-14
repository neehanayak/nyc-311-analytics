import os
import pandas as pd
from dotenv import load_dotenv
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

CSV_PATH = os.path.join(os.path.dirname(__file__), "311_data.csv")
TABLE_NAME = "stg_311_raw"

SNOWFLAKE_CONFIG = {
    "account": os.environ["SNOWFLAKE_ACCOUNT"],
    "user": os.environ["SNOWFLAKE_USER"],
    "private_key_file": os.environ["SNOWFLAKE_PRIVATE_KEY_FILE"],
    "warehouse": os.environ["SNOWFLAKE_WAREHOUSE"],
    "database": os.environ["SNOWFLAKE_DATABASE"],
    "schema": os.environ["SNOWFLAKE_SCHEMA"],
}

if os.environ.get("SNOWFLAKE_ROLE"):
    SNOWFLAKE_CONFIG["role"] = os.environ["SNOWFLAKE_ROLE"]

if os.environ.get("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"):
    SNOWFLAKE_CONFIG["private_key_file_pwd"] = os.environ["SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"]


def load_csv_to_snowflake():
    print(f"Reading {CSV_PATH} ...")
    df = pd.read_csv(CSV_PATH, low_memory=False)

    # Snowflake column names must be uppercase
    df.columns = [c.upper().replace(" ", "_").replace("-", "_") for c in df.columns]

    print(f"Loaded {len(df):,} rows, {len(df.columns)} columns")

    print("Connecting to Snowflake ...")
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)

    try:
        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=df,
            table_name=TABLE_NAME,
            database=SNOWFLAKE_CONFIG["database"],
            schema=SNOWFLAKE_CONFIG["schema"],
            auto_create_table=True,
            overwrite=True,
        )
        if success:
            print(f"Loaded {nrows:,} rows into {SNOWFLAKE_CONFIG['database']}.{SNOWFLAKE_CONFIG['schema']}.{TABLE_NAME}")
        else:
            print("write_pandas reported failure — check Snowflake logs")
    finally:
        conn.close()


if __name__ == "__main__":
    load_csv_to_snowflake()
