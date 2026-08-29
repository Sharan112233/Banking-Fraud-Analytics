# 🏦 Banking Transaction & Fraud Analytics

An end-to-end banking transaction and fraud analytics project built using **Python, PostgreSQL, SQL, and Power BI**.

This project simulates banking transactions, generates controlled suspicious transaction scenarios, loads the data into PostgreSQL, performs data quality and SQL analysis, detects potentially fraudulent transactions using rule-based risk scoring, manages fraud cases, creates reporting views, and presents the results through an interactive Power BI dashboard.

---

## 📌 Project Overview

Financial institutions process large volumes of transactions every day. Identifying suspicious transaction patterns is important for reducing financial losses and supporting fraud investigation.

This project demonstrates a complete analytics workflow:

```text
Data Generation
      ↓
Data Loading
      ↓
PostgreSQL Database
      ↓
Data Quality Analysis
      ↓
SQL Analysis
      ↓
Fraud Detection
      ↓
Risk Scoring
      ↓
Fraud Alerts
      ↓
Fraud Case Management
      ↓
Reporting Views
      ↓
Power BI Dashboard
      ↓
Business Insights
🎯 Project Objectives

The main objectives of this project are:

Build a relational banking database using PostgreSQL.
Generate synthetic banking data using Python.
Generate controlled suspicious transaction scenarios.
Perform data quality validation using SQL.
Analyze customers, accounts, transactions, merchants, and locations.
Detect suspicious transaction patterns.
Assign risk scores to suspicious transactions.
Generate fraud alerts.
Create fraud investigation cases.
Analyze fraud-related financial losses and recovery.
Create PostgreSQL reporting views for Power BI.
Build an interactive Power BI fraud analytics dashboard.
Create a reproducible end-to-end analytics project.
🏗️ Project Architecture
                         PYTHON
                           │
             ┌─────────────┴─────────────┐
             │                           │
      Data Generation          Fraud Scenario Generation
             │                           │
             └─────────────┬─────────────┘
                           ↓
                      CSV DATA
                           ↓
                     POSTGRESQL
                           ↓
                  DATA QUALITY CHECKS
                           ↓
                     SQL ANALYSIS
                           ↓
                   FRAUD DETECTION
                           ↓
                    RISK SCORING
                           ↓
                    FRAUD ALERTS
                           ↓
                 FRAUD CASE MANAGEMENT
                           ↓
                   REPORTING VIEWS
                           ↓
                       POWER BI
                           ↓
                 INTERACTIVE DASHBOARD
🗄️ Database Design

The project uses PostgreSQL as the main relational database.

Entity Relationship Overview
                         ┌──────────────────┐
                         │    customers     │
                         │                  │
                         │ customer_id (PK) │
                         └────────┬─────────┘
                                  │
                                  │ 1:M
                                  ▼
                         ┌──────────────────┐
                         │     accounts     │
                         │                  │
                         │ account_id (PK)  │
                         │ customer_id (FK) │
                         │ branch_id (FK)   │
                         └───────┬──────────┘
                                 │
                                 │ 1:M
                                 ▼
                       ┌────────────────────┐
                       │    transactions    │
                       │                    │
                       │ transaction_id PK  │
                       │ account_id FK      │
                       │ merchant_id FK     │
                       │ location_id FK     │
                       └─────┬────────┬─────┘
                             │        │
                    ┌────────┘        └────────┐
                    ▼                           ▼
          ┌──────────────────┐        ┌──────────────────┐
          │    merchants     │        │    locations     │
          │                  │        │                  │
          │ merchant_id PK   │        │ location_id PK   │
          └──────────────────┘        └──────────────────┘

                       transactions
                              │
                              │
                              ▼
                    ┌──────────────────┐
                    │   fraud_alerts   │
                    │                  │
                    │ alert_id PK      │
                    │ transaction_id FK│
                    └────────┬─────────┘
                             │
                             │
                             ▼
                    ┌──────────────────┐
                    │   fraud_cases    │
                    │                  │
                    │ case_id PK       │
                    │ alert_id FK      │
                    └──────────────────┘

              ┌──────────────────────┐
              │       branches       │
              │                      │
              │ branch_id PK         │
              └──────────┬───────────┘
                         │
                         ▼
                      accounts
📋 Database Tables
Table	Purpose
customers	Customer master information
accounts	Banking account information
branches	Bank branch information
locations	Transaction location information
merchants	Merchant information
transactions	Banking transaction records
fraud_alerts	Suspicious transaction alerts
fraud_cases	Fraud investigation cases
📊 Dataset

The project uses synthetic data generated programmatically using Python.

Current project scale:

Metric	Count
Accounts	7,000
Transactions	206,100
Fraud Alerts	6,097
Fraud Cases	4,441
Highest Risk Score	6

The transaction data contains multiple transaction types:

Credit
Debit
Payment
Transfer
Withdrawal

Transaction records include:

Transaction ID
Account ID
Transaction Date
Transaction Type
Amount
Merchant
Location
Payment Method
Transaction Status
Device ID
Transaction Channel

The dataset is synthetic and created for educational, portfolio, and demonstration purposes.

🚨 Fraud Detection

The project introduces controlled suspicious transaction scenarios and identifies suspicious activity using SQL-based fraud detection rules.

Fraud Scenarios
1. High-Value Transactions

Transactions exceeding a predefined high-value threshold are identified as potentially suspicious.

2. Unusual Transaction Amounts

Transactions with unusually high amounts compared with normal transaction behavior are analyzed.

3. Rapid Transactions

Multiple transactions occurring within a short time period are analyzed for suspicious activity.

4. Multiple Locations

Transactions occurring across multiple locations within a short time period are analyzed for possible account misuse.

5. Multiple Devices

Transactions involving multiple devices within a short period are analyzed for suspicious behavior.

6. Failed → Successful Transactions

Multiple failed transaction attempts followed by a successful transaction are analyzed as a suspicious pattern.

⚠️ Risk Scoring

Multiple fraud indicators can contribute to a transaction's risk score.

                 FRAUD INDICATORS
                        │
        ┌───────────────┼────────────────┐
        │               │                │
    High Value     Rapid Activity   Multiple Devices
        │               │                │
        ├───────────────┼────────────────┤
        │               │                │
 Multiple Locations  Failed → Success  Unusual Amount
        │               │                │
        └───────────────┴────────────────┘
                        │
                        ↓
                   RISK SCORE
                        │
                        ↓
                  FRAUD ALERT

The current project generates risk scores ranging from 2 to 6.

Higher scores indicate a greater concentration of suspicious indicators.

🧠 SQL Analysis

The SQL analysis is divided into separate files to make the project easier to understand and maintain.

sql/
│
├── 01_data_quality.sql
├── 02_customer_analysis.sql
├── 03_transaction_analysis.sql
├── 04_merchant_location_analysis.sql
├── 05_fraud_detection.sql
├── 06_fraud_alerts.sql
├── 07_fraud_case_management.sql
└── 08_reporting_views.sql
SQL Topics Demonstrated
SELECT
WHERE
GROUP BY
HAVING
ORDER BY
Aggregate functions
CASE expressions
JOINs
CTEs
Subqueries
Window functions
Date/time analysis
Duplicate detection
Missing value analysis
Fraud detection logic
Risk scoring
Reporting views
🔎 Data Quality Analysis

The project includes SQL-based data quality checks for:

Missing values
Duplicate records
Invalid values
Transaction amount validation
Referential integrity
Transaction status distribution
Account and transaction consistency

The goal is to validate the data before performing fraud analysis.

🕵️ Fraud Alert Generation

After identifying suspicious transaction patterns, fraud alerts are generated.

Each alert can contain:

Alert ID
Transaction ID
Fraud Rule
Risk Score
Alert Status
Transaction information

The risk score is used to prioritize suspicious transactions.

📁 Fraud Case Management

Fraud alerts can be converted into investigation cases.

Each case contains information such as:

Case ID
Alert ID
Investigation Date
Investigation Result
Loss Amount
Recovery Amount
Net Loss

This allows the project to connect fraud detection with financial impact and investigation.

👁️ PostgreSQL Reporting Views

Four reporting views were created specifically for Power BI.

public vw_transaction_summary
public vw_fraud_alerts
public vw_fraud_cases
public vw_account_fraud_summary
vw_transaction_summary

Provides transaction-level reporting information.

Used for:

Transaction volume
Transaction value
Transaction status
Transaction trends
Transaction type analysis
vw_fraud_alerts

Provides fraud alert information together with relevant transaction details.

Used for:

Fraud alert analysis
Risk analysis
Fraud rule analysis
Suspicious transaction analysis
vw_fraud_cases

Provides fraud investigation and financial impact information.

Used for:

Fraud cases
Investigation status
Loss
Recovery
Net loss
Case-level analysis
vw_account_fraud_summary

Provides account-level transaction and fraud summaries.

Used for:

Account risk analysis
Fraud alert counts
Fraud case counts
Account losses
Recovery
Risk scoring
📈 Power BI Dashboard

The project includes an interactive Power BI dashboard consisting of four analytical pages.

Page 1 — Fraud Executive Overview

Provides a high-level view of the overall fraud situation.

KPIs
Total Transactions
Total Transaction Value
Fraud Alerts
Fraud Cases
Critical Alerts
Fraud Alert Rate
Total Loss
Total Recovery
Net Loss
Recovery Rate
Visuals
Fraud Alerts by Risk Level
Fraud Alerts by Detection Rule
Transaction Value Trend
Fraud Loss vs Recovery
High-Risk Transactions
Risk and transaction filters
Page 2 — Fraud Detection Analysis

Focuses on suspicious transaction patterns and detection rules.

KPIs
Fraud Alerts
Critical Alerts
High Risk Alerts
Suspicious Transaction Value
Highest Risk Score
Visuals
Fraud Alerts by Detection Rule
Fraud Alerts by Risk Score
Fraud Alert Trend
Alerts by Transaction Type
Alerts by Payment Method
Alerts by Transaction Channel
Suspicious Transaction Details
Page 3 — Fraud Investigation

Focuses on fraud cases and financial impact.

KPIs
Total Fraud Cases
Pending Investigations
Total Loss
Total Recovery
Net Loss
Visuals
Cases by Investigation Result
Loss vs Recovery by Risk Level
Fraud Cases by Risk Level
Cases by Fraud Rule
Accounts with Most Fraud Cases
Fraud Case Investigation Details
Page 4 — Account Risk Analysis

Focuses on account-level fraud exposure.

KPIs
Total Accounts
Accounts With Fraud Alerts
High Risk Accounts
Critical Risk Accounts
Highest Risk Score
Visuals
Top Highest-Risk Accounts
Accounts by Risk Score
Top Accounts by Financial Loss
Accounts with Most Fraud Alerts
Accounts with Most Fraud Cases
Account Risk Details
🐍 Python Components

The Python layer is responsible for data generation, fraud scenario generation, and PostgreSQL loading.

python/
│
├── generate_data.py
├── create_fraud_scenarios.py
├── load_data.py
└── load_fraud_transactions.py
generate_data.py

Generates the base synthetic banking datasets.

create_fraud_scenarios.py

Creates controlled suspicious transaction scenarios.

load_data.py

Loads the generated data into PostgreSQL.

load_fraud_transactions.py

Loads the fraud-scenario transaction data into PostgreSQL.

🛠️ Technologies Used
Technology	Purpose
Python	Data generation and processing
Pandas	Data manipulation
NumPy	Numerical operations
Faker	Synthetic data generation
PostgreSQL	Relational database
SQL	Data analysis and fraud detection
Power BI	Data visualization
DAX	KPI calculations
Git	Version control
GitHub	Project hosting
📁 Project Structure
Banking-Fraud-Analytics/
│
├── database/
│   └── schema.sql
│
├── data/
│   ├── accounts.csv
│   ├── branches.csv
│   ├── customers.csv
│   ├── locations.csv
│   ├── merchants.csv
│   └── README.md
│
├── python/
│   ├── generate_data.py
│   ├── create_fraud_scenarios.py
│   ├── load_data.py
│   └── load_fraud_transactions.py
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_customer_analysis.sql
│   ├── 03_transaction_analysis.sql
│   ├── 04_merchant_location_analysis.sql
│   ├── 05_fraud_detection.sql
│   ├── 06_fraud_alerts.sql
│   ├── 07_fraud_case_management.sql
│   └── 08_reporting_views.sql
│
├── powerbi/
│   └── Banking_Fraud_Analytics.pbix
│
├── screenshots/
│
├── .gitignore
├── requirements.txt
└── README.md
⚙️ Setup & Installation
Prerequisites

Install the following:

Python 3.10+
PostgreSQL
pgAdmin 4 (optional)
Power BI Desktop
Git

pgAdmin is a graphical interface for managing PostgreSQL. It is convenient but not strictly required if another PostgreSQL client is used.

1. Clone the Repository
git clone https://github.com/YOUR_USERNAME/Banking-Fraud-Analytics.git

Navigate into the project:

cd Banking-Fraud-Analytics
2. Create a Python Virtual Environment

On Windows:

python -m venv venv

Activate it:

venv\Scripts\activate
3. Install Python Dependencies
pip install -r requirements.txt
4. Create PostgreSQL Database

Create a PostgreSQL database named:

banking_fraud_analytics

This can be done through pgAdmin or another PostgreSQL client.

5. Create Database Tables

Open:

database/schema.sql

Run the script against the newly created PostgreSQL database.

This creates the required tables, constraints, and indexes.

6. Generate Banking Data

Run:

python python/generate_data.py

This generates the base synthetic banking datasets.

7. Generate Fraud Scenarios

Run:

python python/create_fraud_scenarios.py

This creates controlled suspicious transaction scenarios.

8. Load Data into PostgreSQL

Run:

python python/load_data.py

Then:

python python/load_fraud_transactions.py
9. Run SQL Analysis

Run the SQL files in this order:

01_data_quality.sql
02_customer_analysis.sql
03_transaction_analysis.sql
04_merchant_location_analysis.sql
05_fraud_detection.sql
06_fraud_alerts.sql
07_fraud_case_management.sql
08_reporting_views.sql

The order is important because later stages depend on objects and results created by earlier stages.

10. Open Power BI

Open:

powerbi/Banking_Fraud_Analytics.pbix

Connect Power BI to the PostgreSQL database.

The Power BI report uses:

public vw_transaction_summary
public vw_fraud_alerts
public vw_fraud_cases
public vw_account_fraud_summary
📊 Key Project Results

The current generated project contains approximately:

Metric	Result
Accounts	7,000
Transactions	206,100
Fraud Alerts	6,097
Fraud Cases	4,441
Highest Risk Score	6

The generated fraud alerts represent approximately 2.96% of total transactions.

💡 Business Questions Answered

The project helps answer questions such as:

How many transactions were processed?
What is the total transaction value?
What percentage of transactions were flagged?
Which fraud detection rules generate the most alerts?
Which transactions have the highest risk scores?
Which transaction types generate more fraud alerts?
Which payment methods are associated with suspicious activity?
Which transaction channels generate more alerts?
Which accounts have the most fraud alerts?
Which accounts have the most fraud cases?
Which accounts have the highest financial loss?
How much money was lost?
How much money was recovered?
What is the remaining net loss?
Which fraud cases require investigation?
🔐 Data & Security

This project uses synthetic banking data generated for demonstration purposes.

No real customer banking information or financial records are used.

Sensitive information such as:

Database passwords
API keys
Credentials
Environment variables

should never be committed to GitHub.

The .gitignore file is included to help prevent accidental commits of sensitive or unnecessary files.

🚀 Future Improvements

Potential improvements include:

Machine learning-based fraud prediction
Real-time fraud detection
Customer behavioral baselines
Geographic distance analysis
Device fingerprint analysis
Automated fraud alert notifications
Power BI Row-Level Security
Scheduled dashboard refresh
Automated ETL pipelines
Cloud deployment
Fraud prediction using Scikit-learn
Model performance monitoring
Real-time transaction monitoring
📚 Skills Demonstrated
SQL
Data cleaning and validation
Aggregations
JOINs
CTEs
Subqueries
Window functions
CASE expressions
Date/time analysis
Fraud detection
Risk scoring
Reporting views
Python
Pandas
NumPy
Faker
CSV processing
Synthetic data generation
Fraud scenario generation
PostgreSQL connectivity
PostgreSQL
Relational database design
Primary keys
Foreign keys
Constraints
Indexes
Views
Data loading
Analytical SQL
Power BI
Data modeling
Relationships
DAX measures
KPI cards
Slicers
Charts
Tables
Conditional formatting
Interactive dashboard design

🎓 Project Learning Outcomes

This project demonstrates an end-to-end data analytics workflow:

              DATA GENERATION
                     ↓
                DATA LOADING
                     ↓
              DATABASE DESIGN
                     ↓
               DATA QUALITY
                     ↓
                SQL ANALYSIS
                     ↓
             FRAUD DETECTION
                     ↓
               RISK SCORING
                     ↓
              FRAUD ALERTS
                     ↓
           CASE MANAGEMENT
                     ↓
            REPORTING VIEWS
                     ↓
                POWER BI
                     ↓
             BUSINESS INSIGHTS
📸 Dashboard Preview

Dashboard screenshots can be added here.

screenshots/
├── 01_executive_overview.png
├── 02_fraud_detection.png
├── 03_fraud_investigation.png
├── 04_account_risk.png
└── 05_data_methodology.png

Once screenshots are added, they can be displayed using:

## Fraud Executive Overview

![Fraud Executive Overview](screenshots/01_executive_overview.png)

## Fraud Detection Analysis

![Fraud Detection Analysis](screenshots/02_fraud_detection.png)

## Fraud Investigation

![Fraud Investigation](screenshots/03_fraud_investigation.png)

## Account Risk Analysis

![Account Risk Analysis](screenshots/04_account_risk.png)
⭐ Project Highlights
✔ 206K+ synthetic banking transactions
✔ 7K+ banking accounts
✔ Multiple controlled fraud scenarios
✔ SQL-based fraud detection
✔ Risk scoring system
✔ Fraud alert generation
✔ Fraud case management
✔ PostgreSQL relational database
✔ PostgreSQL reporting views
✔ Python data generation pipeline
✔ Advanced SQL analysis
✔ DAX-based Power BI KPIs
✔ Interactive Power BI dashboard
✔ End-to-end analytics workflow
👨‍💻 Author
Sharanabasappa

Data Analytics | SQL | Python | PostgreSQL | Power BI