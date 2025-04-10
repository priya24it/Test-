import pandas as pd
import pyodbc
from google.cloud import bigquery
from pandas._testing import assert_frame_equal

# ---- Step 1: Connect to BigQuery ----
bq_client = bigquery.Client()

# Custom BigQuery query (with corrected partition date logic)
bq_query = """
    SELECT * 
    FROM `prj-d-data-platform-4922.landing_trips.arvest_posted_transaction_falcon_error` 
    WHERE DATE(_PARTITIONTIME) = '2025-04-10'
    LIMIT 1000
"""

# Run BigQuery query and load into DataFrame
df_bq = bq_client.query(bq_query).to_dataframe()

# ---- Step 2: Connect to SQL Server using Windows Authentication ----
conn_str = (
    r"Driver={ODBC Driver 17 for SQL Server};"
    r"Server=YOUR_SERVER_NAME;"
    r"Database=YOUR_DATABASE_NAME;"
    r"Trusted_Connection=yes;"
)
sql_conn = pyodbc.connect(conn_str)

# ---- Step 3: Execute SQL Server Queries (adjust your table/logic) ----
sql_query = "SELECT * FROM dbo.arvest_posted_transaction_falcon_error WHERE CAST([PartitionColumn] AS DATE) = '2025-04-10'"
df_sql = pd.read_sql(sql_query, sql_conn)

# ---- Step 4: Prepare and Align Columns ----
df_bq = df_bq.sort_index(axis=1)
df_sql = df_sql.sort_index(axis=1)

common_cols = df_bq.columns.intersection(df_sql.columns)
df_bq = df_bq[common_cols]
df_sql = df_sql[common_cols]

# Reset index to align row-wise
df_bq = df_bq.reset_index(drop=True)
df_sql = df_sql.reset_index(drop=True)

# ---- Step 5: Compare ----
comparison_result = df_bq.compare(df_sql, keep_shape=True, keep_equal=False)

# ---- Step 6: Display or Save Results ----
if not comparison_result.empty:
    print("❌ Differences found:")
    print(comparison_result)
    comparison_result.to_csv("bq_vs_sql_diff.csv", index=False)
else:
    print("✅ No differences. Data matches!")

# ---- Optional: Close SQL connection ----
sql_conn.close()
