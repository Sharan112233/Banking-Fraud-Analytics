import pandas as pd
import psycopg2
from pathlib import Path
from psycopg2.extras import execute_values


# ============================================================
# CONFIGURATION
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_FILE = (
    BASE_DIR
    / "data"
    / "transactions_with_fraud_scenarios.csv"
)


# ============================================================
# DATABASE CONFIGURATION
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "port": "5432",
    "database": "banking_fraud_analytics",
    "user": "postgres",
    "password": "1234"
}


# ============================================================
# LOAD CSV
# ============================================================

print("=" * 60)
print("LOADING FRAUD TRANSACTIONS INTO POSTGRESQL")
print("=" * 60)

print("\nReading transaction file...")

df = pd.read_csv(
    DATA_FILE,
    parse_dates=["transaction_date"]
)

print(
    f"✓ Loaded {len(df):,} transactions from CSV"
)


# ============================================================
# CHECK REQUIRED COLUMNS
# ============================================================

required_columns = [
    "transaction_id",
    "account_id",
    "transaction_date",
    "transaction_type",
    "amount",
    "merchant_id",
    "location_id",
    "payment_method",
    "transaction_status",
    "device_id",
    "transaction_channel"
]

missing_columns = [
    column
    for column in required_columns
    if column not in df.columns
]

if missing_columns:

    raise ValueError(
        f"Missing columns: {missing_columns}"
    )


print("✓ All required columns are present")


# ============================================================
# CHECK DUPLICATE TRANSACTION IDs
# ============================================================

duplicate_count = (
    df["transaction_id"]
    .duplicated()
    .sum()
)

if duplicate_count > 0:

    raise ValueError(
        f"Found {duplicate_count} duplicate transaction IDs"
    )


print("✓ No duplicate transaction IDs")


# ============================================================
# DATABASE CONNECTION
# ============================================================

try:

    connection = psycopg2.connect(
        **DB_CONFIG
    )

    cursor = connection.cursor()

    print(
        "✓ PostgreSQL connection successful!"
    )

except Exception as e:

    print(
        f"❌ Database connection failed: {e}"
    )

    raise


# ============================================================
# CLEAR EXISTING TRANSACTIONS
# ============================================================

try:

    print(
        "\nRemoving existing transactions..."
    )

    cursor.execute(
        "DELETE FROM transactions;"
    )

    deleted_rows = cursor.rowcount

    print(
        f"✓ Deleted {deleted_rows:,} old transactions"
    )


    # ========================================================
    # PREPARE DATA
    # ========================================================

    print(
        "\nPreparing transactions for insertion..."
    )

    data = [

        (
            row.transaction_id,
            row.account_id,
            row.transaction_date,
            row.transaction_type,
            row.amount,
            row.merchant_id,
            row.location_id,
            row.payment_method,
            row.transaction_status,
            row.device_id,
            row.transaction_channel
        )

        for row in df.itertuples(index=False)
    ]


    # ========================================================
    # INSERT TRANSACTIONS
    # ========================================================

    insert_query = """
        INSERT INTO transactions (
            transaction_id,
            account_id,
            transaction_date,
            transaction_type,
            amount,
            merchant_id,
            location_id,
            payment_method,
            transaction_status,
            device_id,
            transaction_channel
        )
        VALUES %s
    """


    print(
        f"\nInserting {len(data):,} transactions..."
    )

    execute_values(
        cursor,
        insert_query,
        data,
        page_size=5000
    )

    print(
        "✓ Transactions inserted successfully"
    )


    # ========================================================
    # COMMIT
    # ========================================================

    connection.commit()

    print(
        "✓ Changes committed to PostgreSQL"
    )


    # ========================================================
    # VERIFY DATA
    # ========================================================

    cursor.execute(
        "SELECT COUNT(*) FROM transactions;"
    )

    database_count = cursor.fetchone()[0]


    print(
        f"\nTransactions in database: "
        f"{database_count:,}"
    )


    # ========================================================
    # VERIFY FRAUD TRANSACTIONS
    # ========================================================

    cursor.execute(
        """
        SELECT COUNT(*)
        FROM transactions
        WHERE transaction_id LIKE 'FRAUD%';
        """
    )

    fraud_count = cursor.fetchone()[0]


    print(
        f"Fraud scenario transactions: "
        f"{fraud_count:,}"
    )


    # ========================================================
    # TRANSACTION STATUS SUMMARY
    # ========================================================

    print(
        "\nTransaction status distribution:"
    )

    cursor.execute(
        """
        SELECT
            transaction_status,
            COUNT(*) AS transaction_count
        FROM transactions
        GROUP BY transaction_status
        ORDER BY transaction_count DESC;
        """
    )

    status_results = cursor.fetchall()

    for status, count in status_results:

        print(
            f"  {status}: {count:,}"
        )


except Exception as e:

    connection.rollback()

    print(
        f"\n❌ Error while loading transactions: {e}"
    )

    raise


finally:

    cursor.close()

    connection.close()

    print(
        "\n✓ Database connection closed"
    )


# ============================================================
# FINAL SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("FRAUD TRANSACTION LOAD COMPLETED")
print("=" * 60)

print(
    f"CSV transactions     : {len(df):,}"
)

print(
    f"Database transactions : {database_count:,}"
)

print(
    f"Fraud scenario rows   : {fraud_count:,}"
)

print(
    "\n✓ Ready for SQL fraud detection."
)