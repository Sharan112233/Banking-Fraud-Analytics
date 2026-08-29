-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: database/schema.sql
-- PURPOSE: Recreate the complete PostgreSQL database structure
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (

    customer_id VARCHAR(20) PRIMARY KEY,

    first_name VARCHAR(100) NOT NULL,

    last_name VARCHAR(100) NOT NULL,

    date_of_birth DATE,

    gender VARCHAR(20),

    email VARCHAR(150),

    phone VARCHAR(30),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    customer_since DATE,

    customer_segment VARCHAR(50)

);


-- ============================================================
-- 2. BRANCHES
-- ============================================================

CREATE TABLE IF NOT EXISTS branches (

    branch_id VARCHAR(20) PRIMARY KEY,

    branch_name VARCHAR(150) NOT NULL,

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    branch_type VARCHAR(50),

    manager_name VARCHAR(150)

);


-- ============================================================
-- 3. ACCOUNTS
-- ============================================================

CREATE TABLE IF NOT EXISTS accounts (

    account_id VARCHAR(20) PRIMARY KEY,

    customer_id VARCHAR(20) NOT NULL,

    branch_id VARCHAR(20),

    account_type VARCHAR(50),

    account_status VARCHAR(50),

    opening_date DATE,

    current_balance NUMERIC(18,2),

    credit_limit NUMERIC(18,2),

    currency VARCHAR(10),

    CONSTRAINT fk_accounts_customer

        FOREIGN KEY (customer_id)

        REFERENCES customers(customer_id),

    CONSTRAINT fk_accounts_branch

        FOREIGN KEY (branch_id)

        REFERENCES branches(branch_id)

);


-- ============================================================
-- 4. LOCATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS locations (

    location_id VARCHAR(20) PRIMARY KEY,

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    latitude NUMERIC(10,6),

    longitude NUMERIC(10,6),

    location_type VARCHAR(50)

);


-- ============================================================
-- 5. MERCHANTS
-- ============================================================

CREATE TABLE IF NOT EXISTS merchants (

    merchant_id VARCHAR(20) PRIMARY KEY,

    merchant_name VARCHAR(150) NOT NULL,

    merchant_category VARCHAR(100),

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100),

    risk_category VARCHAR(50)

);


-- ============================================================
-- 6. TRANSACTIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS transactions (

    transaction_id VARCHAR(30) PRIMARY KEY,

    account_id VARCHAR(20) NOT NULL,

    transaction_date TIMESTAMP NOT NULL,

    transaction_type VARCHAR(50),

    amount NUMERIC(18,2) NOT NULL,

    merchant_id VARCHAR(20),

    location_id VARCHAR(20),

    payment_method VARCHAR(50),

    transaction_status VARCHAR(50),

    device_id VARCHAR(100),

    transaction_channel VARCHAR(50),

    CONSTRAINT fk_transactions_account

        FOREIGN KEY (account_id)

        REFERENCES accounts(account_id),

    CONSTRAINT fk_transactions_merchant

        FOREIGN KEY (merchant_id)

        REFERENCES merchants(merchant_id),

    CONSTRAINT fk_transactions_location

        FOREIGN KEY (location_id)

        REFERENCES locations(location_id)

);


-- ============================================================
-- 7. FRAUD ALERTS
-- ============================================================

CREATE TABLE IF NOT EXISTS fraud_alerts (

    alert_id VARCHAR(40) PRIMARY KEY,

    transaction_id VARCHAR(30) NOT NULL,

    fraud_rule VARCHAR(200),

    risk_score INTEGER,

    alert_status VARCHAR(50),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alert_transaction

        FOREIGN KEY (transaction_id)

        REFERENCES transactions(transaction_id)

);


-- ============================================================
-- 8. FRAUD CASES
-- ============================================================

CREATE TABLE IF NOT EXISTS fraud_cases (

    case_id VARCHAR(40) PRIMARY KEY,

    alert_id VARCHAR(40) NOT NULL,

    investigation_date DATE,

    investigation_result VARCHAR(100),

    loss_amount NUMERIC(18,2) DEFAULT 0,

    recovery_amount NUMERIC(18,2) DEFAULT 0,

    CONSTRAINT fk_case_alert

        FOREIGN KEY (alert_id)

        REFERENCES fraud_alerts(alert_id)

);


-- ============================================================
-- INDEXES
-- ============================================================

-- Customer lookup
CREATE INDEX IF NOT EXISTS idx_accounts_customer_id
ON accounts(customer_id);


-- Branch lookup
CREATE INDEX IF NOT EXISTS idx_accounts_branch_id
ON accounts(branch_id);


-- Transaction account lookup
CREATE INDEX IF NOT EXISTS idx_transactions_account_id
ON transactions(account_id);


-- Transaction date lookup
CREATE INDEX IF NOT EXISTS idx_transactions_transaction_date
ON transactions(transaction_date);


-- Merchant lookup
CREATE INDEX IF NOT EXISTS idx_transactions_merchant_id
ON transactions(merchant_id);


-- Location lookup
CREATE INDEX IF NOT EXISTS idx_transactions_location_id
ON transactions(location_id);


-- Transaction status lookup
CREATE INDEX IF NOT EXISTS idx_transactions_status
ON transactions(transaction_status);


-- Fraud alert transaction lookup
CREATE INDEX IF NOT EXISTS idx_fraud_alerts_transaction_id
ON fraud_alerts(transaction_id);


-- Fraud alert risk lookup
CREATE INDEX IF NOT EXISTS idx_fraud_alerts_risk_score
ON fraud_alerts(risk_score);


-- Fraud case alert lookup
CREATE INDEX IF NOT EXISTS idx_fraud_cases_alert_id
ON fraud_cases(alert_id);


-- ============================================================
-- DATABASE STRUCTURE SUMMARY
-- ============================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT
    'branches',
    COUNT(*)
FROM branches

UNION ALL

SELECT
    'accounts',
    COUNT(*)
FROM accounts

UNION ALL

SELECT
    'locations',
    COUNT(*)
FROM locations

UNION ALL

SELECT
    'merchants',
    COUNT(*)
FROM merchants

UNION ALL

SELECT
    'transactions',
    COUNT(*)
FROM transactions

UNION ALL

SELECT
    'fraud_alerts',
    COUNT(*)
FROM fraud_alerts

UNION ALL

SELECT
    'fraud_cases',
    COUNT(*)
FROM fraud_cases

ORDER BY table_name;


-- ============================================================
-- END OF SCHEMA
-- ============================================================