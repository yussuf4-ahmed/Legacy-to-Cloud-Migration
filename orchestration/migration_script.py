# Legacy to Cloud Migration Script
# Orchestrates the migration of historical data from legacy systems to Snowflake.

import os
import pandas as pd
from sqlalchemy import create_engine, text
from snowflake.connector.pandas_tools import write_pandas
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

# 1. Postgres Connection
pg_url = f"postgresql://{os.getenv('PG_USER')}:{os.getenv('PG_PASSWORD')}@{os.getenv('PG_HOST')}:{os.getenv('PG_PORT')}/{os.getenv('PG_DATABASE')}"
pg_engine = create_engine(pg_url)

# 2. Snowflake Connection Function
def get_sf_connection():
    return snowflake.connector.connect(
        user=os.getenv('SF_USER'),
        password=os.getenv('SF_PASSWORD'),
        account=os.getenv('SF_ACCOUNT'),
        warehouse="MIGRATION_WH",
        database=os.getenv('SF_DATABASE'),
        schema=os.getenv('SF_SCHEMA'),
        role=os.getenv('SF_ROLE')
    )

tables = ['patients', 'doctors', 'facilities', 'encounters']

def migrate():
    print("--- Starting Migration: Legacy to Cloud (Native Mode) ---")
    
    ctx = get_sf_connection()
    
    for table in tables:
        try:
            # EXTRACT
            print(f"Reading {table} from Postgres...")
            query = f'SELECT * FROM "legacy".{table}'
            df = pd.read_sql_query(text(query), pg_engine.connect())
            
            # TRANSFORM
            # FIX: Convert current time to a string format so Snowflake doesn't treat it as a long integer
            df['EXTRACTED_AT_TIMESTAMP'] = pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # Ensure all column names are Uppercase for Snowflake
            df.columns = [x.upper() for x in df.columns]
            
            # LOAD
            print(f"Uploading {len(df)} rows to Snowflake: {table.upper()}...")
            
            # write_pandas is the high-speed way to move DataFrames
            success, nchunks, nrows, _ = write_pandas(
                conn=ctx,
                df=df,
                table_name=table.upper(),
                database=os.getenv('SF_DATABASE'),
                schema=os.getenv('SF_SCHEMA'),
                auto_create_table=True, 
                overwrite=True
            )
            
            if success:
                print(f"✅ Success: {nrows} rows migrated for {table.upper()}.")
            
        except Exception as e:
            print(f"❌ Error migrating {table}: {e}")

    ctx.close()
    print("--- Migration Complete ---")

if __name__ == "__main__":
    migrate()
