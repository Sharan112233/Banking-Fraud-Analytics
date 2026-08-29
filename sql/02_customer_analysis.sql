-- ============================================================
-- 1. CUSTOMERS BY STATE
-- ============================================================

SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;


-- ============================================================
-- 2. CUSTOMERS BY RISK CATEGORY
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
-- 3. CUSTOMERS BY GENDER
-- ============================================================

SELECT
    gender,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customers
GROUP BY gender
ORDER BY customer_count DESC;

-- ============================================================
-- 4. ACCOUNTS PER CUSTOMER
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(a.account_id) AS account_count
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY account_count DESC;

-- ============================================================
-- 5. CUSTOMERS WITH MULTIPLE ACCOUNTS
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(a.account_id) AS account_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY account_count DESC;

-- ============================================================
-- 6. TOTAL BALANCE BY CUSTOMER
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(a.account_id) AS account_count,
    ROUND(SUM(a.current_balance), 2) AS total_balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_balance DESC;

-- ============================================================
-- 7. TOP 10 CUSTOMERS BY BALANCE
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(a.current_balance), 2) AS total_balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_balance DESC
LIMIT 10;


-- ============================================================
-- 8. CUSTOMER TRANSACTION SUMMARY
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2) AS total_transaction_amount,

    ROUND(AVG(t.amount), 2) AS average_transaction_amount,

    ROUND(MAX(t.amount), 2) AS highest_transaction

FROM customers c

JOIN accounts a
    ON c.customer_id = a.customer_id

JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_transaction_amount DESC;

-- ============================================================
-- 9. TOP 10 CUSTOMERS BY TRANSACTION VALUE
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2) AS total_transaction_amount

FROM customers c

JOIN accounts a
    ON c.customer_id = a.customer_id

JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_transaction_amount DESC

LIMIT 10;


-- ============================================================
-- 10. TRANSACTION BEHAVIOR BY CUSTOMER RISK
-- ============================================================

SELECT
    c.risk_category,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2) AS total_transaction_amount,

    ROUND(AVG(t.amount), 2) AS average_transaction_amount

FROM customers c

JOIN accounts a
    ON c.customer_id = a.customer_id

JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY c.risk_category

ORDER BY total_transaction_amount DESC;


-- ============================================================
-- 11. TOP CUSTOMERS WITHIN EACH RISK CATEGORY
-- ============================================================

WITH customer_spending AS (

    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.risk_category,

        ROUND(SUM(t.amount), 2) AS total_spending

    FROM customers c

    JOIN accounts a
        ON c.customer_id = a.customer_id

    JOIN transactions t
        ON a.account_id = t.account_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.risk_category
),

ranked_customers AS (

    SELECT
        *,
        RANK() OVER (
            PARTITION BY risk_category
            ORDER BY total_spending DESC
        ) AS spending_rank

    FROM customer_spending
)

SELECT *
FROM ranked_customers
WHERE spending_rank <= 5
ORDER BY
    risk_category,
    spending_rank;



-- ============================================================
-- 12. CUSTOMER TRANSACTION RANKING
-- ============================================================

WITH customer_transactions AS (

    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,

        ROUND(SUM(t.amount), 2) AS total_transaction_amount

    FROM customers c

    JOIN accounts a
        ON c.customer_id = a.customer_id

    JOIN transactions t
        ON a.account_id = t.account_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    *,
    DENSE_RANK() OVER (
        ORDER BY total_transaction_amount DESC
    ) AS customer_rank

FROM customer_transactions
ORDER BY customer_rank;


