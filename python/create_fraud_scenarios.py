import pandas as pd
import numpy as np
import random
from pathlib import Path


# ============================================================
# CONFIGURATION
# ============================================================

random.seed(42)
np.random.seed(42)

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

TRANSACTIONS_FILE = DATA_DIR / "transactions.csv"
OUTPUT_FILE = DATA_DIR / "transactions_with_fraud_scenarios.csv"

NUM_HIGH_VALUE = 500
NUM_RAPID = 400
NUM_LOCATION = 400
NUM_FAILED_SUCCESS = 300
NUM_DEVICE = 400


# ============================================================
# LOAD EXISTING TRANSACTIONS
# ============================================================

print("=" * 60)
print("BANKING FRAUD SCENARIO GENERATOR")
print("=" * 60)

print("\nLoading existing transactions...")

transactions = pd.read_csv(
    TRANSACTIONS_FILE,
    parse_dates=["transaction_date"]
)

print(
    f"✓ Loaded {len(transactions):,} transactions"
)


# ============================================================
# LOAD REFERENCE DATA
# ============================================================

accounts = pd.read_csv(
    DATA_DIR / "accounts.csv"
)

merchants = pd.read_csv(
    DATA_DIR / "merchants.csv"
)

locations = pd.read_csv(
    DATA_DIR / "locations.csv"
)


account_ids = accounts["account_id"].tolist()
merchant_ids = merchants["merchant_id"].tolist()
location_ids = locations["location_id"].tolist()


# ============================================================
# HELPER FUNCTION
# ============================================================

def create_transaction(
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
):

    return {
        "transaction_id": transaction_id,
        "account_id": account_id,
        "transaction_date": transaction_date,
        "transaction_type": transaction_type,
        "amount": round(float(amount), 2),
        "merchant_id": merchant_id,
        "location_id": location_id,
        "payment_method": payment_method,
        "transaction_status": transaction_status,
        "device_id": device_id,
        "transaction_channel": transaction_channel
    }


# ============================================================
# START FRAUD TRANSACTIONS
# ============================================================

fraud_transactions = []

fraud_counter = 1


# ============================================================
# SCENARIO 1: HIGH-VALUE TRANSACTIONS
# ============================================================

print("\nCreating high-value transactions...")

for i in range(NUM_HIGH_VALUE):

    account_id = random.choice(account_ids)

    transaction_date = pd.Timestamp(
        "2025-01-01"
    ) + pd.Timedelta(
        days=random.randint(0, 364),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59)
    )

    amount = random.uniform(
        150000,
        500000
    )

    fraud_transactions.append(
        create_transaction(
            transaction_id=f"FRAUD{fraud_counter:07d}",
            account_id=account_id,
            transaction_date=transaction_date,
            transaction_type="Transfer",
            amount=amount,
            merchant_id=random.choice(merchant_ids),
            location_id=random.choice(location_ids),
            payment_method=random.choice([
                "UPI",
                "Net Banking",
                "Bank Transfer"
            ]),
            transaction_status="Completed",
            device_id=f"FDEV{random.randint(1, 500):05d}",
            transaction_channel=random.choice([
                "Mobile App",
                "Internet Banking"
            ])
        )
    )

    fraud_counter += 1


print(
    f"✓ Created {NUM_HIGH_VALUE} high-value transactions"
)


# ============================================================
# SCENARIO 2: RAPID MULTIPLE TRANSACTIONS
# ============================================================

print("\nCreating rapid transaction patterns...")

for i in range(NUM_RAPID):

    account_id = random.choice(account_ids)

    base_time = pd.Timestamp(
        "2025-01-01"
    ) + pd.Timedelta(
        days=random.randint(0, 364),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59)
    )

    # Create 5 transactions within a few minutes
    for j in range(5):

        transaction_date = (
            base_time
            + pd.Timedelta(
                seconds=j * random.randint(30, 90)
            )
        )

        amount = random.uniform(
            5000,
            25000
        )

        fraud_transactions.append(
            create_transaction(
                transaction_id=f"FRAUD{fraud_counter:07d}",
                account_id=account_id,
                transaction_date=transaction_date,
                transaction_type="Payment",
                amount=amount,
                merchant_id=random.choice(merchant_ids),
                location_id=random.choice(location_ids),
                payment_method=random.choice([
                    "UPI",
                    "Debit Card",
                    "Credit Card"
                ]),
                transaction_status="Completed",
                device_id=f"FDEV{random.randint(1, 500):05d}",
                transaction_channel="Mobile App"
            )
        )

        fraud_counter += 1


print(
    f"✓ Created {NUM_RAPID * 5:,} rapid transactions"
)


# ============================================================
# SCENARIO 3: MULTIPLE LOCATIONS
# ============================================================

print("\nCreating multiple-location patterns...")

for i in range(NUM_LOCATION):

    account_id = random.choice(account_ids)

    base_time = pd.Timestamp(
        "2025-01-01"
    ) + pd.Timedelta(
        days=random.randint(0, 364),
        hours=random.randint(0, 23)
    )

    selected_locations = random.sample(
        location_ids,
        3
    )

    for j, location_id in enumerate(
        selected_locations
    ):

        transaction_date = (
            base_time
            + pd.Timedelta(
                minutes=j * random.randint(2, 5)
            )
        )

        amount = random.uniform(
            10000,
            50000
        )

        fraud_transactions.append(
            create_transaction(
                transaction_id=f"FRAUD{fraud_counter:07d}",
                account_id=account_id,
                transaction_date=transaction_date,
                transaction_type="Payment",
                amount=amount,
                merchant_id=random.choice(merchant_ids),
                location_id=location_id,
                payment_method=random.choice([
                    "UPI",
                    "Debit Card",
                    "Credit Card"
                ]),
                transaction_status="Completed",
                device_id=f"FDEV{random.randint(1, 500):05d}",
                transaction_channel="Mobile App"
            )
        )

        fraud_counter += 1


print(
    f"✓ Created {NUM_LOCATION * 3:,} multiple-location transactions"
)


# ============================================================
# SCENARIO 4: FAILED ATTEMPTS FOLLOWED BY SUCCESS
# ============================================================

print(
    "\nCreating failed-attempt followed by success patterns..."
)

for i in range(NUM_FAILED_SUCCESS):

    account_id = random.choice(account_ids)

    base_time = pd.Timestamp(
        "2025-01-01"
    ) + pd.Timedelta(
        days=random.randint(0, 364),
        hours=random.randint(0, 23)
    )

    # Three failed attempts
    for j in range(3):

        transaction_date = (
            base_time
            + pd.Timedelta(
                minutes=j + 1
            )
        )

        fraud_transactions.append(
            create_transaction(
                transaction_id=f"FRAUD{fraud_counter:07d}",
                account_id=account_id,
                transaction_date=transaction_date,
                transaction_type="Payment",
                amount=random.uniform(
                    20000,
                    50000
                ),
                merchant_id=random.choice(merchant_ids),
                location_id=random.choice(location_ids),
                payment_method=random.choice([
                    "UPI",
                    "Debit Card",
                    "Credit Card"
                ]),
                transaction_status="Failed",
                device_id=f"FDEV{random.randint(1, 500):05d}",
                transaction_channel="Mobile App"
            )
        )

        fraud_counter += 1

    # Successful large transaction
    success_time = (
        base_time
        + pd.Timedelta(
            minutes=5
        )
    )

    fraud_transactions.append(
        create_transaction(
            transaction_id=f"FRAUD{fraud_counter:07d}",
            account_id=account_id,
            transaction_date=success_time,
            transaction_type="Transfer",
            amount=random.uniform(
                100000,
                300000
            ),
            merchant_id=random.choice(merchant_ids),
            location_id=random.choice(location_ids),
            payment_method="Bank Transfer",
            transaction_status="Completed",
            device_id=f"FDEV{random.randint(1, 500):05d}",
            transaction_channel="Internet Banking"
        )
    )

    fraud_counter += 1


print(
    f"✓ Created {NUM_FAILED_SUCCESS * 4:,} failed/success transactions"
)


# ============================================================
# SCENARIO 5: MULTIPLE DEVICES
# ============================================================

print("\nCreating multiple-device patterns...")

for i in range(NUM_DEVICE):

    account_id = random.choice(account_ids)

    base_time = pd.Timestamp(
        "2025-01-01"
    ) + pd.Timedelta(
        days=random.randint(0, 364),
        hours=random.randint(0, 23)
    )

    devices = [
        f"FDEV{random.randint(1, 500):05d}",
        f"FDEV{random.randint(501, 1000):05d}",
        f"FDEV{random.randint(1001, 1500):05d}"
    ]

    for j, device_id in enumerate(devices):

        transaction_date = (
            base_time
            + pd.Timedelta(
                minutes=j * 2
            )
        )

        amount = random.uniform(
            15000,
            75000
        )

        fraud_transactions.append(
            create_transaction(
                transaction_id=f"FRAUD{fraud_counter:07d}",
                account_id=account_id,
                transaction_date=transaction_date,
                transaction_type="Payment",
                amount=amount,
                merchant_id=random.choice(merchant_ids),
                location_id=random.choice(location_ids),
                payment_method=random.choice([
                    "UPI",
                    "Debit Card",
                    "Credit Card"
                ]),
                transaction_status="Completed",
                device_id=device_id,
                transaction_channel="Mobile App"
            )
        )

        fraud_counter += 1


print(
    f"✓ Created {NUM_DEVICE * 3:,} multiple-device transactions"
)


# ============================================================
# CONVERT TO DATAFRAME
# ============================================================

fraud_df = pd.DataFrame(
    fraud_transactions
)


# ============================================================
# COMBINE WITH NORMAL TRANSACTIONS
# ============================================================

print("\nCombining normal and suspicious transactions...")

combined_transactions = pd.concat(
    [
        transactions,
        fraud_df
    ],
    ignore_index=True
)


# ============================================================
# REMOVE ANY DUPLICATE TRANSACTION IDs
# ============================================================

combined_transactions = (
    combined_transactions
    .drop_duplicates(
        subset=["transaction_id"]
    )
)


# ============================================================
# SORT BY DATE
# ============================================================

combined_transactions = (
    combined_transactions
    .sort_values(
        "transaction_date"
    )
    .reset_index(drop=True)
)


# ============================================================
# SAVE OUTPUT
# ============================================================

combined_transactions.to_csv(
    OUTPUT_FILE,
    index=False
)


# ============================================================
# SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("FRAUD SCENARIO GENERATION COMPLETED")
print("=" * 60)

print(
    f"Original transactions : {len(transactions):,}"
)

print(
    f"Suspicious transactions: {len(fraud_df):,}"
)

print(
    f"Final transactions     : {len(combined_transactions):,}"
)

print(
    f"\nOutput file:"
)

print(OUTPUT_FILE)

print("\nSuspicious transaction breakdown:")

print(
    f"High-value              : {NUM_HIGH_VALUE:,}"
)

print(
    f"Rapid transactions      : {NUM_RAPID * 5:,}"
)

print(
    f"Multiple locations      : {NUM_LOCATION * 3:,}"
)

print(
    f"Failed → successful     : {NUM_FAILED_SUCCESS * 4:,}"
)

print(
    f"Multiple devices        : {NUM_DEVICE * 3:,}"
)

print("\n✓ Ready for SQL fraud detection.")