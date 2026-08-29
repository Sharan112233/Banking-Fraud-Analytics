import psycopg2
from pathlib import Path
import csv

import os
from dotenv import load_dotenv

load_dotenv()

# ============================================
# DATABASE CONFIGURATION
# ============================================

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT", "5432"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}


# ============================================
# PROJECT PATH
# ============================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"


# ============================================
# CSV → POSTGRESQL LOADER
# ============================================

def load_csv_to_table(connection, csv_file, table_name):

    print(f"\nLoading {table_name}...")

    file_path = DATA_DIR / csv_file

    cursor = connection.cursor()

    try:

        with open(
            file_path,
            "r",
            encoding="utf-8"
        ) as file:

            reader = csv.reader(file)

            # Skip CSV header
            next(reader)

            rows = list(reader)

        # Clear existing data
        cursor.execute(
            f"TRUNCATE TABLE {table_name} CASCADE;"
        )

        # Insert rows
        for row in rows:

            placeholders = ", ".join(
                ["%s"] * len(row)
            )

            cursor.execute(
                f"""
                INSERT INTO {table_name}
                VALUES ({placeholders})
                """,
                row
            )

        connection.commit()

        print(
            f"✓ {table_name}: {len(rows):,} rows loaded"
        )

    except Exception as error:

        connection.rollback()

        print(
            f"✗ Error loading {table_name}:"
        )

        print(error)

        raise

    finally:

        cursor.close()


# ============================================
# MAIN PROGRAM
# ============================================

def main():

    print("=" * 60)
    print("BANKING FRAUD ANALYTICS")
    print("POSTGRESQL DATA LOADER")
    print("=" * 60)

    connection = psycopg2.connect(**DB_CONFIG)

    print("\n✓ PostgreSQL connection successful!")

    # IMPORTANT:
    # Load tables in foreign-key order

    tables = [
        ("branches.csv", "branches"),
        ("locations.csv", "locations"),
        ("merchants.csv", "merchants"),
        ("customers.csv", "customers"),
        ("accounts.csv", "accounts"),
        ("transactions.csv", "transactions")
    ]

    for csv_file, table_name in tables:

        load_csv_to_table(
            connection,
            csv_file,
            table_name
        )

    connection.close()

    print("\n" + "=" * 60)
    print("DATA LOADING COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()