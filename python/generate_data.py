import pandas as pd
import numpy as np
from faker import Faker
from pathlib import Path
import random

# ============================================
# CONFIGURATION
# ============================================

fake = Faker("en_IN")

# Make results reproducible
random.seed(42)
np.random.seed(42)
Faker.seed(42)

# Number of records
NUM_CUSTOMERS = 5000
NUM_ACCOUNTS = 7000
NUM_BRANCHES = 50
NUM_MERCHANTS = 1000
NUM_LOCATIONS = 100

# Project directories
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

DATA_DIR.mkdir(exist_ok=True)

print("Starting data generation...")
print(f"Data will be saved to: {DATA_DIR}")


# ============================================
# 1. GENERATE BRANCHES
# ============================================

print("\nGenerating branches...")

indian_states = [
    "Karnataka",
    "Maharashtra",
    "Tamil Nadu",
    "Telangana",
    "Kerala",
    "Delhi",
    "Gujarat",
    "West Bengal",
    "Rajasthan",
    "Uttar Pradesh"
]

cities_by_state = {
    "Karnataka": ["Bengaluru", "Mysuru", "Mangaluru", "Hubballi"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
    "Telangana": ["Hyderabad", "Warangal"],
    "Kerala": ["Kochi", "Thiruvananthapuram", "Kozhikode"],
    "Delhi": ["New Delhi"],
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara"],
    "West Bengal": ["Kolkata"],
    "Rajasthan": ["Jaipur", "Udaipur"],
    "Uttar Pradesh": ["Lucknow", "Kanpur", "Noida"]
}

branch_records = []

for i in range(1, NUM_BRANCHES + 1):

    state = random.choice(indian_states)
    city = random.choice(cities_by_state[state])

    branch_records.append({
        "branch_id": f"BR{i:04d}",
        "branch_name": f"{city} Branch {i}",
        "city": city,
        "state": state
    })

branches_df = pd.DataFrame(branch_records)

branches_df.to_csv(
    DATA_DIR / "branches.csv",
    index=False
)

print(f"✓ Generated {len(branches_df)} branches")


# ============================================
# 2. GENERATE LOCATIONS
# ============================================

print("\nGenerating locations...")

location_records = []

location_id = 1

for state, cities in cities_by_state.items():

    for city in cities:

        location_records.append({
            "location_id": f"LOC{location_id:04d}",
            "city": city,
            "state": state,
            "country": "India"
        })

        location_id += 1


# If we need more locations, randomly create duplicates
while len(location_records) < NUM_LOCATIONS:

    state = random.choice(indian_states)
    city = random.choice(cities_by_state[state])

    location_records.append({
        "location_id": f"LOC{location_id:04d}",
        "city": city,
        "state": state,
        "country": "India"
    })

    location_id += 1


locations_df = pd.DataFrame(location_records[:NUM_LOCATIONS])

locations_df.to_csv(
    DATA_DIR / "locations.csv",
    index=False
)

print(f"✓ Generated {len(locations_df)} locations")


# ============================================
# 3. GENERATE MERCHANTS
# ============================================

print("\nGenerating merchants...")

merchant_categories = [
    "Grocery",
    "Restaurant",
    "Electronics",
    "Online Shopping",
    "Travel",
    "Healthcare",
    "Fuel",
    "Entertainment",
    "Clothing",
    "Jewelry",
    "Education",
    "Utilities"
]

merchant_records = []

for i in range(1, NUM_MERCHANTS + 1):

    state = random.choice(indian_states)
    city = random.choice(cities_by_state[state])
    category = random.choice(merchant_categories)

    merchant_records.append({
        "merchant_id": f"MER{i:05d}",
        "merchant_name": f"{category} Merchant {i}",
        "merchant_category": category,
        "city": city,
        "state": state
    })

merchants_df = pd.DataFrame(merchant_records)

merchants_df.to_csv(
    DATA_DIR / "merchants.csv",
    index=False
)

print(f"✓ Generated {len(merchants_df)} merchants")


# ============================================
# 4. GENERATE CUSTOMERS
# ============================================

print("\nGenerating customers...")

customer_records = []

risk_categories = [
    "Low",
    "Medium",
    "High"
]

risk_probabilities = [
    0.70,
    0.25,
    0.05
]

for i in range(1, NUM_CUSTOMERS + 1):

    gender = random.choice(["Male", "Female"])

    first_name = fake.first_name_male() if gender == "Male" else fake.first_name_female()

    last_name = fake.last_name()

    state = random.choice(indian_states)
    city = random.choice(cities_by_state[state])

    customer_records.append({
        "customer_id": f"CUST{i:05d}",
        "first_name": first_name,
        "last_name": last_name,
        "date_of_birth": fake.date_of_birth(
            minimum_age=18,
            maximum_age=70
        ),
        "gender": gender,
        "city": city,
        "state": state,
        "customer_since": fake.date_between(
            start_date="-8y",
            end_date="-1y"
        ),
        "risk_category": np.random.choice(
            risk_categories,
            p=risk_probabilities
        )
    })

customers_df = pd.DataFrame(customer_records)

customers_df.to_csv(
    DATA_DIR / "customers.csv",
    index=False
)

print(f"✓ Generated {len(customers_df)} customers")


# ============================================
# 5. GENERATE ACCOUNTS
# ============================================

print("\nGenerating accounts...")

account_types = [
    "Savings",
    "Current",
    "Salary"
]

account_statuses = [
    "Active",
    "Inactive",
    "Blocked"
]

account_records = []

customer_ids = customers_df["customer_id"].tolist()
branch_ids = branches_df["branch_id"].tolist()

for i in range(1, NUM_ACCOUNTS + 1):

    customer_id = random.choice(customer_ids)

    account_records.append({
        "account_id": f"ACC{i:06d}",
        "customer_id": customer_id,
        "account_type": random.choice(account_types),
        "account_open_date": fake.date_between(
            start_date="-7y",
            end_date="today"
        ),
        "branch_id": random.choice(branch_ids),
        "current_balance": round(
            np.random.lognormal(
                mean=10,
                sigma=1.2
            ),
            2
        ),
        "account_status": random.choices(
            account_statuses,
            weights=[0.94, 0.04, 0.02]
        )[0]
    })

accounts_df = pd.DataFrame(account_records)

accounts_df.to_csv(
    DATA_DIR / "accounts.csv",
    index=False
)

print(f"✓ Generated {len(accounts_df)} accounts")


# ============================================
# FINAL SUMMARY
# ============================================

print("\n" + "=" * 50)
print("MASTER DATA GENERATION COMPLETED")
print("=" * 50)

print(f"Customers  : {len(customers_df):,}")
print(f"Accounts   : {len(accounts_df):,}")
print(f"Branches   : {len(branches_df):,}")
print(f"Merchants  : {len(merchants_df):,}")
print(f"Locations  : {len(locations_df):,}")

print("\nFiles created:")

for file in sorted(DATA_DIR.glob("*.csv")):
    print(f"  ✓ {file.name}")

print("\nNext step: Generate transaction data.")
# ============================================
# 6. GENERATE TRANSACTIONS
# ============================================

print("\nGenerating transactions...")

NUM_TRANSACTIONS = 200_000

transaction_types = [
    "Debit",
    "Credit",
    "Transfer",
    "Withdrawal",
    "Payment"
]

transaction_type_weights = [
    0.40,
    0.15,
    0.15,
    0.10,
    0.20
]

payment_methods = [
    "UPI",
    "Debit Card",
    "Credit Card",
    "Net Banking",
    "ATM",
    "Bank Transfer"
]

transaction_channels = [
    "Mobile App",
    "Internet Banking",
    "ATM",
    "POS",
    "Branch"
]

transaction_statuses = [
    "Completed",
    "Failed",
    "Pending"
]

account_ids = accounts_df["account_id"].tolist()
merchant_ids = merchants_df["merchant_id"].tolist()
location_ids = locations_df["location_id"].tolist()

transaction_records = []

# Generate transaction dates between Jan 1, 2025 and Dec 31, 2025
start_date = pd.Timestamp("2025-01-01")
end_date = pd.Timestamp("2025-12-31")

random_timestamps = pd.to_datetime(
    np.random.randint(
        start_date.value // 10**9,
        end_date.value // 10**9,
        size=NUM_TRANSACTIONS
    ),
    unit="s"
)

for i in range(NUM_TRANSACTIONS):

    transaction_type = np.random.choice(
        transaction_types,
        p=transaction_type_weights
    )

    # Different transaction types have different
    # typical transaction amounts

    if transaction_type == "Debit":
        amount = np.random.lognormal(
            mean=7.5,
            sigma=1.0
        )

    elif transaction_type == "Credit":
        amount = np.random.lognormal(
            mean=8.5,
            sigma=1.0
        )

    elif transaction_type == "Transfer":
        amount = np.random.lognormal(
            mean=9.0,
            sigma=1.1
        )

    elif transaction_type == "Withdrawal":
        amount = np.random.lognormal(
            mean=7.0,
            sigma=0.8
        )

    else:
        amount = np.random.lognormal(
            mean=7.0,
            sigma=1.0
        )

    # Keep normal transactions within reasonable limits
    amount = min(amount, 100_000)

    # Round amount
    amount = round(amount, 2)

    transaction_records.append({
        "transaction_id": f"TXN{i + 1:08d}",
        "account_id": random.choice(account_ids),
        "transaction_date": random_timestamps[i],
        "transaction_type": transaction_type,
        "amount": amount,
        "merchant_id": random.choice(merchant_ids),
        "location_id": random.choice(location_ids),
        "payment_method": random.choice(payment_methods),
        "transaction_status": random.choices(
            transaction_statuses,
            weights=[0.96, 0.03, 0.01]
        )[0],
        "device_id": f"DEV{random.randint(1, 15000):06d}",
        "transaction_channel": random.choice(
            transaction_channels
        )
    })


transactions_df = pd.DataFrame(transaction_records)

# Sort transactions chronologically
transactions_df = transactions_df.sort_values(
    "transaction_date"
).reset_index(drop=True)

# Save to CSV
transactions_df.to_csv(
    DATA_DIR / "transactions.csv",
    index=False
)

print(f"✓ Generated {len(transactions_df):,} transactions")

print("\nTransaction summary:")

print(
    transactions_df[
        [
            "transaction_type",
            "amount"
        ]
    ].groupby("transaction_type")
    .agg(
        transaction_count=("amount", "count"),
        total_amount=("amount", "sum"),
        average_amount=("amount", "mean")
    )
    .round(2)
)

print("\nTransaction status distribution:")

print(
    transactions_df["transaction_status"]
    .value_counts()
)

print("\nTransaction data saved to:")

print(DATA_DIR / "transactions.csv")