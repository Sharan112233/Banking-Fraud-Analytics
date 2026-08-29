```sql
-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 03_transaction_analysis.sql
-- PURPOSE: Transaction analysis and behavioral analysis
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: BASIC TRANSACTION OVERVIEW
-- ============================================================


-- 1. TOTAL NUMBER OF TRANSACTIONS

SELECT
    COUNT(*) AS total_transactions
FROM transactions;


-- 2. TOTAL TRANSACTION VALUE

SELECT
    ROUND(SUM(amount), 2) AS total_transaction_value
FROM transactions;


-- 3. AVERAGE TRANSACTION VALUE

SELECT
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions;


-- 4. MINIMUM AND MAXIMUM TRANSACTION

SELECT
    ROUND(MIN(amount), 2) AS minimum_transaction,
    ROUND(MAX(amount), 2) AS maximum_transaction
FROM transactions;


-- 5. TRANSACTION DATE RANGE

SELECT
    MIN(transaction_date) AS first_transaction,
    MAX(transaction_date) AS last_transaction
FROM transactions;



-- ============================================================
-- SECTION 2: TRANSACTION TYPE ANALYSIS
-- ============================================================


-- 6. TRANSACTIONS BY TYPE

SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;


-- 7. TRANSACTION VALUE BY TYPE

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_amount DESC;


-- 8. TRANSACTION TYPE PERCENTAGE

SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS transaction_percentage
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_percentage DESC;


-- 9. HIGHEST TRANSACTION BY TYPE

SELECT
    transaction_type,
    ROUND(MAX(amount), 2) AS highest_transaction
FROM transactions
GROUP BY transaction_type
ORDER BY highest_transaction DESC;



-- ============================================================
-- SECTION 3: TRANSACTION STATUS ANALYSIS
-- ============================================================


-- 10. TRANSACTIONS BY STATUS

SELECT
    transaction_status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_status
ORDER BY transaction_count DESC;


-- 11. TRANSACTION STATUS PERCENTAGE

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS percentage
FROM transactions
GROUP BY transaction_status
ORDER BY percentage DESC;


-- 12. TRANSACTION VALUE BY STATUS

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY transaction_status
ORDER BY total_amount DESC;



-- ============================================================
-- SECTION 4: PAYMENT METHOD ANALYSIS
-- ============================================================


-- 13. TRANSACTIONS BY PAYMENT METHOD

SELECT
    payment_method,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_method
ORDER BY transaction_count DESC;


-- 14. TRANSACTION VALUE BY PAYMENT METHOD

SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY payment_method
ORDER BY total_amount DESC;


-- 15. PAYMENT METHOD USAGE PERCENTAGE

SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS usage_percentage
FROM transactions
GROUP BY payment_method
ORDER BY usage_percentage DESC;



-- ============================================================
-- SECTION 5: TRANSACTION CHANNEL ANALYSIS
-- ============================================================


-- 16. TRANSACTIONS BY CHANNEL

SELECT
    transaction_channel,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_channel
ORDER BY transaction_count DESC;


-- 17. TRANSACTION VALUE BY CHANNEL

SELECT
    transaction_channel,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY transaction_channel
ORDER BY total_amount DESC;



-- ============================================================
-- SECTION 6: MONTHLY TRANSACTION ANALYSIS
-- ============================================================


-- 18. TRANSACTIONS BY MONTH

SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;


-- 19. MONTHLY TRANSACTION VALUE

SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    ROUND(SUM(amount), 2) AS total_transaction_value
FROM transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;


-- 20. MONTH-OVER-MONTH TRANSACTION GROWTH

WITH monthly_transactions AS (

    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY DATE_TRUNC('month', transaction_date)

),

monthly_comparison AS (

    SELECT
        month,
        total_amount,
        LAG(total_amount) OVER (
            ORDER BY month
        ) AS previous_month_amount
    FROM monthly_transactions

)

SELECT
    month,

    ROUND(total_amount, 2)
        AS current_month_amount,

    ROUND(previous_month_amount, 2)
        AS previous_month_amount,

    ROUND(
        (
            total_amount - previous_month_amount
        )
        /
        NULLIF(previous_month_amount, 0)
        * 100,
        2
    ) AS month_over_month_growth_percentage

FROM monthly_comparison

ORDER BY month;



-- ============================================================
-- SECTION 7: DAILY TRANSACTION ANALYSIS
-- ============================================================


-- 21. DAILY TRANSACTION VOLUME

SELECT
    DATE(transaction_date) AS transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY DATE(transaction_date)
ORDER BY transaction_date;


-- 22. TOP 10 DAYS BY TRANSACTION VALUE

SELECT
    DATE(transaction_date) AS transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY DATE(transaction_date)
ORDER BY total_amount DESC
LIMIT 10;


-- 23. TOP 10 DAYS BY TRANSACTION COUNT

SELECT
    DATE(transaction_date) AS transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY DATE(transaction_date)
ORDER BY transaction_count DESC
LIMIT 10;



-- ============================================================
-- SECTION 8: DAY OF WEEK ANALYSIS
-- ============================================================


-- 24. TRANSACTIONS BY DAY OF WEEK

SELECT
    EXTRACT(DOW FROM transaction_date) AS day_number,

    TRIM(
        TO_CHAR(transaction_date, 'Day')
    ) AS day_of_week,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2) AS total_amount

FROM transactions

GROUP BY
    EXTRACT(DOW FROM transaction_date),
    TRIM(TO_CHAR(transaction_date, 'Day'))

ORDER BY day_number;


-- 25. WEEKDAY VS WEEKEND

SELECT
    CASE
        WHEN EXTRACT(DOW FROM transaction_date) IN (0, 6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2) AS total_amount,

    ROUND(AVG(amount), 2) AS average_amount

FROM transactions

GROUP BY
    CASE
        WHEN EXTRACT(DOW FROM transaction_date) IN (0, 6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END

ORDER BY transaction_count DESC;



-- ============================================================
-- SECTION 9: HOURLY TRANSACTION ANALYSIS
-- ============================================================


-- 26. TRANSACTIONS BY HOUR

SELECT
    EXTRACT(HOUR FROM transaction_date) AS transaction_hour,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2) AS total_amount

FROM transactions

GROUP BY EXTRACT(HOUR FROM transaction_date)

ORDER BY transaction_hour;


-- 27. TOP 5 PEAK TRANSACTION HOURS

SELECT
    EXTRACT(HOUR FROM transaction_date) AS transaction_hour,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2) AS total_amount

FROM transactions

GROUP BY EXTRACT(HOUR FROM transaction_date)

ORDER BY transaction_count DESC

LIMIT 5;



-- ============================================================
-- SECTION 10: HIGH-VALUE TRANSACTION ANALYSIS
-- ============================================================


-- 28. TRANSACTIONS ABOVE 50,000

SELECT
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount,
    payment_method
FROM transactions
WHERE amount > 50000
ORDER BY amount DESC;


-- 29. TRANSACTIONS ABOVE 100,000

SELECT
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount,
    payment_method
FROM transactions
WHERE amount > 100000
ORDER BY amount DESC;


-- 30. HIGH-VALUE TRANSACTION SUMMARY

SELECT
    COUNT(*) AS high_value_transactions,
    ROUND(SUM(amount), 2) AS total_high_value_amount,
    ROUND(AVG(amount), 2) AS average_high_value_amount
FROM transactions
WHERE amount > 50000;



-- ============================================================
-- SECTION 11: TRANSACTION AMOUNT DISTRIBUTION
-- ============================================================


-- 31. TRANSACTION AMOUNT BANDS

WITH transaction_bands AS (

    SELECT
        amount,

        CASE
            WHEN amount < 1000
                THEN 'Below 1,000'

            WHEN amount < 5000
                THEN '1,000 - 4,999'

            WHEN amount < 10000
                THEN '5,000 - 9,999'

            WHEN amount < 50000
                THEN '10,000 - 49,999'

            WHEN amount < 100000
                THEN '50,000 - 99,999'

            ELSE '100,000+'

        END AS amount_band

    FROM transactions

)

SELECT
    amount_band,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2) AS total_amount,

    ROUND(AVG(amount), 2) AS average_amount

FROM transaction_bands

GROUP BY amount_band

ORDER BY MIN(amount);



-- ============================================================
-- SECTION 12: CUSTOMER TRANSACTION BEHAVIOR
-- ============================================================


-- 32. CUSTOMER TRANSACTION SUMMARY

SELECT

    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_amount,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_amount,

    ROUND(MAX(t.amount), 2)
        AS highest_transaction

FROM customers AS c

JOIN accounts AS a
    ON c.customer_id = a.customer_id

JOIN transactions AS t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_transaction_amount DESC;


-- 33. TOP 20 CUSTOMERS BY TRANSACTION VALUE

SELECT

    c.customer_id,
    c.first_name,
    c.last_name,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_amount

FROM customers AS c

JOIN accounts AS a
    ON c.customer_id = a.customer_id

JOIN transactions AS t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_transaction_amount DESC

LIMIT 20;



-- ============================================================
-- SECTION 13: TRANSACTION ACTIVITY BY LOCATION
-- ============================================================


-- 34. TRANSACTIONS BY STATE

SELECT

    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_amount,

    ROUND(AVG(t.amount), 2)
        AS average_amount

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY l.state

ORDER BY total_amount DESC;


-- 35. TRANSACTIONS BY CITY

SELECT

    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_amount

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.city,
    l.state

ORDER BY total_amount DESC;



-- ============================================================
-- SECTION 14: MERCHANT ANALYSIS
-- ============================================================


-- 36. TRANSACTIONS BY MERCHANT CATEGORY

SELECT

    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_amount,

    ROUND(AVG(t.amount), 2)
        AS average_amount

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

GROUP BY m.merchant_category

ORDER BY total_amount DESC;


-- 37. TOP 20 MERCHANTS BY TRANSACTION VALUE

SELECT

    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_amount

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

ORDER BY total_amount DESC

LIMIT 20;



-- ============================================================
-- SECTION 15: FAILED TRANSACTION ANALYSIS
-- ============================================================


-- 38. FAILED TRANSACTIONS BY PAYMENT METHOD

SELECT

    payment_method,

    COUNT(*) AS failed_transactions,

    ROUND(SUM(amount), 2)
        AS failed_transaction_value

FROM transactions

WHERE transaction_status = 'Failed'

GROUP BY payment_method

ORDER BY failed_transactions DESC;


-- 39. FAILED TRANSACTIONS BY CHANNEL

SELECT

    transaction_channel,

    COUNT(*) AS failed_transactions,

    ROUND(SUM(amount), 2)
        AS failed_transaction_value

FROM transactions

WHERE transaction_status = 'Failed'

GROUP BY transaction_channel

ORDER BY failed_transactions DESC;


-- 40. FAILED TRANSACTION RATE BY PAYMENT METHOD

SELECT

    payment_method,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE transaction_status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE transaction_status = 'Failed'
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate_percentage

FROM transactions

GROUP BY payment_method

ORDER BY failure_rate_percentage DESC;



-- ============================================================
-- SECTION 16: ADVANCED WINDOW FUNCTIONS
-- ============================================================


-- 41. CUSTOMER TRANSACTION RANKING

WITH customer_transactions AS (

    SELECT

        c.customer_id,
        c.first_name,
        c.last_name,

        SUM(t.amount) AS total_amount

    FROM customers AS c

    JOIN accounts AS a
        ON c.customer_id = a.customer_id

    JOIN transactions AS t
        ON a.account_id = t.account_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name

)

SELECT

    customer_id,
    first_name,
    last_name,

    ROUND(total_amount, 2)
        AS total_amount,

    DENSE_RANK() OVER (
        ORDER BY total_amount DESC
    ) AS customer_rank

FROM customer_transactions

ORDER BY customer_rank;


-- 42. MONTHLY TRANSACTION RANKING

WITH monthly_transactions AS (

    SELECT

        DATE_TRUNC(
            'month',
            transaction_date
        ) AS month,

        SUM(amount) AS total_amount

    FROM transactions

    GROUP BY DATE_TRUNC(
        'month',
        transaction_date
    )

)

SELECT

    month,

    ROUND(total_amount, 2)
        AS total_amount,

    RANK() OVER (
        ORDER BY total_amount DESC
    ) AS monthly_rank

FROM monthly_transactions

ORDER BY month;


-- 43. RUNNING TOTAL OF TRANSACTION VALUE

WITH monthly_transactions AS (

    SELECT

        DATE_TRUNC(
            'month',
            transaction_date
        ) AS month,

        SUM(amount) AS total_amount

    FROM transactions

    GROUP BY DATE_TRUNC(
        'month',
        transaction_date
    )

)

SELECT

    month,

    ROUND(total_amount, 2)
        AS monthly_amount,

    ROUND(
        SUM(total_amount) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS running_total

FROM monthly_transactions

ORDER BY month;



-- ============================================================
-- SECTION 17: ADVANCED CUSTOMER BEHAVIOR
-- ============================================================


-- 44. TRANSACTIONS MORE THAN 3 TIMES
--     THE CUSTOMER'S AVERAGE

WITH customer_average AS (

    SELECT

        c.customer_id,

        AVG(t.amount)
            AS average_transaction

    FROM customers AS c

    JOIN accounts AS a
        ON c.customer_id = a.customer_id

    JOIN transactions AS t
        ON a.account_id = t.account_id

    GROUP BY c.customer_id

)

SELECT

    c.customer_id,
    c.first_name,
    c.last_name,

    ROUND(ca.average_transaction, 2)
        AS customer_average,

    t.transaction_id,
    t.transaction_date,

    ROUND(t.amount, 2)
        AS transaction_amount

FROM customer_average AS ca

JOIN customers AS c
    ON ca.customer_id = c.customer_id

JOIN accounts AS a
    ON c.customer_id = a.customer_id

JOIN transactions AS t
    ON a.account_id = t.account_id

WHERE t.amount > ca.average_transaction * 3

ORDER BY t.amount DESC;


-- 45. CUSTOMER MONTHLY TRANSACTION ACTIVITY

SELECT

    c.customer_id,
    c.first_name,
    c.last_name,

    DATE_TRUNC(
        'month',
        t.transaction_date
    ) AS month,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_amount

FROM customers AS c

JOIN accounts AS a
    ON c.customer_id = a.customer_id

JOIN transactions AS t
    ON a.account_id = t.account_id

GROUP BY

    c.customer_id,
    c.first_name,
    c.last_name,

    DATE_TRUNC(
        'month',
        t.transaction_date
    )

ORDER BY
    c.customer_id,
    month;



-- ============================================================
-- SECTION 18: FRAUD ANALYSIS PREPARATION
-- ============================================================


-- 46. HIGH-VALUE TRANSACTIONS BY LOCATION

SELECT

    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS high_value_transactions,

    ROUND(SUM(t.amount), 2)
        AS total_high_value_amount,

    ROUND(AVG(t.amount), 2)
        AS average_high_value_amount

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

WHERE t.amount > 50000

GROUP BY
    l.city,
    l.state

ORDER BY total_high_value_amount DESC;


-- 47. HIGH-VALUE TRANSACTIONS BY MERCHANT CATEGORY

SELECT

    m.merchant_category,

    COUNT(t.transaction_id)
        AS high_value_transactions,

    ROUND(SUM(t.amount), 2)
        AS total_amount

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

WHERE t.amount > 50000

GROUP BY m.merchant_category

ORDER BY total_amount DESC;


-- 48. CUSTOMER TRANSACTIONS ABOVE 50,000

SELECT

    c.customer_id,
    c.first_name,
    c.last_name,

    t.transaction_id,
    t.transaction_date,

    ROUND(t.amount, 2)
        AS amount,

    t.transaction_type,
    t.payment_method

FROM transactions AS t

JOIN accounts AS a
    ON t.account_id = a.account_id

JOIN customers AS c
    ON a.customer_id = c.customer_id

WHERE t.amount > 50000

ORDER BY t.amount DESC;


-- ============================================================
-- END OF TRANSACTION ANALYSIS
-- ============================================================
```
