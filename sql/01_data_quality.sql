-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 01_data_quality.sql
-- PURPOSE: Validate the quality and integrity of the data
-- ============================================================


-- ============================================================
-- 1. TABLE ROW COUNTS
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'accounts', COUNT(*)
FROM accounts

UNION ALL

SELECT 'branches', COUNT(*)
FROM branches

UNION ALL

SELECT 'merchants', COUNT(*)
FROM merchants

UNION ALL

SELECT 'locations', COUNT(*)
FROM locations

UNION ALL

SELECT 'transactions', COUNT(*)
FROM transactions;


-- ============================================================
-- 2. CHECK FOR DUPLICATE CUSTOMER IDs
-- Expected: 0 rows
-- ============================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. CHECK FOR DUPLICATE ACCOUNT IDs
-- Expected: 0 rows
-- ============================================================

SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CHECK FOR DUPLICATE TRANSACTION IDs
-- Expected: 0 rows
-- ============================================================

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. CHECK NULL VALUES IN CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS null_first_name,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS null_last_name,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE state IS NULL) AS null_state,
    COUNT(*) FILTER (WHERE customer_since IS NULL) AS null_customer_since,
    COUNT(*) FILTER (WHERE risk_category IS NULL) AS null_risk_category
FROM customers;


-- ============================================================
-- 6. CHECK NULL VALUES IN ACCOUNTS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS null_account_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE account_type IS NULL) AS null_account_type,
    COUNT(*) FILTER (WHERE account_open_date IS NULL) AS null_open_date,
    COUNT(*) FILTER (WHERE branch_id IS NULL) AS null_branch_id,
    COUNT(*) FILTER (WHERE current_balance IS NULL) AS null_balance,
    COUNT(*) FILTER (WHERE account_status IS NULL) AS null_status
FROM accounts;


-- ============================================================
-- 7. CHECK NULL VALUES IN TRANSACTIONS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS null_transaction_id,
    COUNT(*) FILTER (WHERE account_id IS NULL) AS null_account_id,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS null_transaction_date,
    COUNT(*) FILTER (WHERE transaction_type IS NULL) AS null_transaction_type,
    COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount,
    COUNT(*) FILTER (WHERE merchant_id IS NULL) AS null_merchant_id,
    COUNT(*) FILTER (WHERE location_id IS NULL) AS null_location_id,
    COUNT(*) FILTER (WHERE payment_method IS NULL) AS null_payment_method,
    COUNT(*) FILTER (WHERE transaction_status IS NULL) AS null_status
FROM transactions;


-- ============================================================
-- 8. CHECK INVALID TRANSACTION AMOUNTS
-- Expected: 0 rows
-- ============================================================

SELECT
    COUNT(*) AS invalid_transactions
FROM transactions
WHERE amount <= 0;


-- ============================================================
-- 9. CHECK TRANSACTION DATE RANGE
-- ============================================================

SELECT
    MIN(transaction_date) AS first_transaction,
    MAX(transaction_date) AS last_transaction
FROM transactions;


-- ============================================================
-- 10. TRANSACTION STATUS DISTRIBUTION
-- ============================================================

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM transactions
GROUP BY transaction_status
ORDER BY transaction_count DESC;


-- ============================================================
-- 11. TRANSACTION TYPE DISTRIBUTION
-- ============================================================

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_amount DESC;


-- ============================================================
-- 12. CHECK ACCOUNT -> CUSTOMER RELATIONSHIP
-- Expected: 0 invalid accounts
-- ============================================================

SELECT
    COUNT(*) AS invalid_accounts
FROM accounts a
LEFT JOIN customers c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- 13. CHECK TRANSACTION -> ACCOUNT RELATIONSHIP
-- Expected: 0 invalid transactions
-- ============================================================

SELECT
    COUNT(*) AS invalid_transactions
FROM transactions t
LEFT JOIN accounts a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 14. CHECK TRANSACTION -> MERCHANT RELATIONSHIP
-- Expected: 0 invalid transactions
-- ============================================================

SELECT
    COUNT(*) AS invalid_merchant_references
FROM transactions t
LEFT JOIN merchants m
    ON t.merchant_id = m.merchant_id
WHERE m.merchant_id IS NULL;


-- ============================================================
-- 15. CHECK TRANSACTION -> LOCATION RELATIONSHIP
-- Expected: 0 invalid transactions
-- ============================================================

SELECT
    COUNT(*) AS invalid_location_references
FROM transactions t
LEFT JOIN locations l
    ON t.location_id = l.location_id
WHERE l.location_id IS NULL;


-- ============================================================
-- 16. CHECK ACCOUNT -> BRANCH RELATIONSHIP
-- Expected: 0 invalid accounts
-- ============================================================

SELECT
    COUNT(*) AS invalid_branch_references
FROM accounts a
LEFT JOIN branches b
    ON a.branch_id = b.branch_id
WHERE b.branch_id IS NULL;


-- ============================================================
-- 17. CHECK CUSTOMER RISK CATEGORIES
-- ============================================================

SELECT
    risk_category,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customers
GROUP BY risk_category
ORDER BY customer_count DESC;


-- ============================================================
-- 18. CHECK ACCOUNT STATUS
-- ============================================================

SELECT
    account_status,
    COUNT(*) AS account_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM accounts
GROUP BY account_status
ORDER BY account_count DESC;


-- ============================================================
-- 19. CHECK NEGATIVE ACCOUNT BALANCES
-- ============================================================

SELECT
    COUNT(*) AS negative_balance_accounts
FROM accounts
WHERE current_balance < 0;


-- ============================================================
-- 20. BASIC DATA QUALITY SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM accounts) AS accounts,
    (SELECT COUNT(*) FROM branches) AS branches,
    (SELECT COUNT(*) FROM merchants) AS merchants,
    (SELECT COUNT(*) FROM locations) AS locations,
    (SELECT COUNT(*) FROM transactions) AS transactions;