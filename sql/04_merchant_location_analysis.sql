-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 04_merchant_location_analysis.sql
-- PURPOSE: Merchant and Location Analysis
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: MERCHANT OVERVIEW
-- ============================================================


-- 1. TOTAL NUMBER OF MERCHANTS

SELECT
    COUNT(*) AS total_merchants
FROM merchants;


-- 2. MERCHANTS BY CATEGORY

SELECT
    merchant_category,
    COUNT(*) AS merchant_count
FROM merchants
GROUP BY merchant_category
ORDER BY merchant_count DESC;


-- 3. MERCHANTS BY STATE

SELECT
    state,
    COUNT(*) AS merchant_count
FROM merchants
GROUP BY state
ORDER BY merchant_count DESC;


-- 4. MERCHANTS BY CITY

SELECT
    city,
    state,
    COUNT(*) AS merchant_count
FROM merchants
GROUP BY
    city,
    state
ORDER BY merchant_count DESC;



-- ============================================================
-- SECTION 2: MERCHANT TRANSACTION ANALYSIS
-- ============================================================


-- 5. TRANSACTIONS BY MERCHANT

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

ORDER BY total_transaction_value DESC;


-- 6. TOP 20 MERCHANTS BY TRANSACTION VALUE

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

ORDER BY total_transaction_value DESC

LIMIT 20;


-- 7. TOP 20 MERCHANTS BY TRANSACTION COUNT

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(t.transaction_id) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

ORDER BY transaction_count DESC

LIMIT 20;



-- ============================================================
-- SECTION 3: MERCHANT CATEGORY ANALYSIS
-- ============================================================


-- 8. TRANSACTION ACTIVITY BY MERCHANT CATEGORY

SELECT
    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY m.merchant_category

ORDER BY total_transaction_value DESC;


-- 9. MERCHANT CATEGORY TRANSACTION VALUE PERCENTAGE

SELECT
    m.merchant_category,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(
        SUM(t.amount) * 100.0 /
        (SELECT SUM(amount) FROM transactions),
        2
    ) AS transaction_value_percentage

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY m.merchant_category

ORDER BY transaction_value_percentage DESC;


-- 10. HIGHEST TRANSACTION BY MERCHANT CATEGORY

SELECT
    m.merchant_category,

    ROUND(MAX(t.amount), 2)
        AS highest_transaction,

    ROUND(AVG(t.amount), 2)
        AS average_transaction

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY m.merchant_category

ORDER BY highest_transaction DESC;



-- ============================================================
-- SECTION 4: LOCATION OVERVIEW
-- ============================================================


-- 11. TOTAL LOCATIONS

SELECT
    COUNT(*) AS total_locations
FROM locations;


-- 12. LOCATIONS BY STATE

SELECT
    state,
    COUNT(*) AS location_count
FROM locations
GROUP BY state
ORDER BY location_count DESC;


-- 13. LOCATIONS BY CITY

SELECT
    city,
    state,
    COUNT(*) AS location_count
FROM locations
GROUP BY
    city,
    state
ORDER BY location_count DESC;



-- ============================================================
-- SECTION 5: TRANSACTION ACTIVITY BY LOCATION
-- ============================================================


-- 14. TRANSACTIONS BY STATE

SELECT
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY l.state

ORDER BY total_transaction_value DESC;


-- 15. TRANSACTIONS BY CITY

SELECT
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY
    l.city,
    l.state

ORDER BY total_transaction_value DESC;


-- 16. TOP 20 CITIES BY TRANSACTION VALUE

SELECT
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY
    l.city,
    l.state

ORDER BY total_transaction_value DESC

LIMIT 20;


-- 17. TOP 20 CITIES BY TRANSACTION COUNT

SELECT
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY
    l.city,
    l.state

ORDER BY transaction_count DESC

LIMIT 20;



-- ============================================================
-- SECTION 6: HIGH-VALUE TRANSACTIONS BY LOCATION
-- ============================================================


-- 18. HIGH-VALUE TRANSACTIONS BY STATE

SELECT
    l.state,

    COUNT(t.transaction_id)
        AS high_value_transactions,

    ROUND(SUM(t.amount), 2)
        AS total_high_value_amount,

    ROUND(AVG(t.amount), 2)
        AS average_high_value_amount

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

WHERE t.amount > 50000

GROUP BY l.state

ORDER BY total_high_value_amount DESC;


-- 19. HIGH-VALUE TRANSACTIONS BY CITY

SELECT
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS high_value_transactions,

    ROUND(SUM(t.amount), 2)
        AS total_high_value_amount,

    ROUND(AVG(t.amount), 2)
        AS average_high_value_amount

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

WHERE t.amount > 50000

GROUP BY
    l.city,
    l.state

ORDER BY total_high_value_amount DESC;


-- 20. TOP 20 CITIES BY HIGH-VALUE TRANSACTIONS

SELECT
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS high_value_transaction_count,

    ROUND(MAX(t.amount), 2)
        AS highest_transaction,

    ROUND(SUM(t.amount), 2)
        AS total_high_value_amount

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

WHERE t.amount > 50000

GROUP BY
    l.city,
    l.state

ORDER BY high_value_transaction_count DESC

LIMIT 20;



-- ============================================================
-- SECTION 7: MERCHANT + TRANSACTION LOCATION ANALYSIS
-- ============================================================


-- 21. MERCHANT CATEGORY BY TRANSACTION STATE

SELECT
    l.state,
    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.state,
    m.merchant_category

ORDER BY
    l.state,
    total_transaction_value DESC;


-- 22. MERCHANT CATEGORY BY TRANSACTION CITY

SELECT
    l.city,
    l.state,
    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.city,
    l.state,
    m.merchant_category

ORDER BY total_transaction_value DESC;


-- 23. TOP MERCHANTS WITHIN EACH CATEGORY

WITH merchant_summary AS (

    SELECT
        m.merchant_id,
        m.merchant_name,
        m.merchant_category,

        COUNT(t.transaction_id)
            AS transaction_count,

        SUM(t.amount)
            AS total_transaction_value

    FROM merchants AS m

    JOIN transactions AS t
        ON m.merchant_id = t.merchant_id

    GROUP BY
        m.merchant_id,
        m.merchant_name,
        m.merchant_category
),

ranked_merchants AS (

    SELECT
        *,
        RANK() OVER (
            PARTITION BY merchant_category
            ORDER BY total_transaction_value DESC
        ) AS category_rank

    FROM merchant_summary
)

SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    transaction_count,

    ROUND(total_transaction_value, 2)
        AS total_transaction_value,

    category_rank

FROM ranked_merchants

WHERE category_rank <= 5

ORDER BY
    merchant_category,
    category_rank;



-- ============================================================
-- SECTION 8: PAYMENT METHOD + LOCATION
-- ============================================================


-- 24. PAYMENT METHOD BY STATE

SELECT
    l.state,
    t.payment_method,

    COUNT(*) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.state,
    t.payment_method

ORDER BY
    l.state,
    transaction_count DESC;


-- 25. PAYMENT METHOD BY CITY

SELECT
    l.city,
    l.state,
    t.payment_method,

    COUNT(*) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.city,
    l.state,
    t.payment_method

ORDER BY total_transaction_value DESC;



-- ============================================================
-- SECTION 9: FAILED TRANSACTIONS BY LOCATION
-- ============================================================


-- 26. FAILED TRANSACTIONS BY STATE

SELECT
    l.state,

    COUNT(*) AS failed_transactions,

    ROUND(SUM(t.amount), 2)
        AS failed_transaction_value

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

WHERE t.transaction_status = 'Failed'

GROUP BY l.state

ORDER BY failed_transactions DESC;


-- 27. FAILED TRANSACTIONS BY CITY

SELECT
    l.city,
    l.state,

    COUNT(*) AS failed_transactions,

    ROUND(SUM(t.amount), 2)
        AS failed_transaction_value

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

WHERE t.transaction_status = 'Failed'

GROUP BY
    l.city,
    l.state

ORDER BY failed_transactions DESC;


-- 28. FAILURE RATE BY STATE

SELECT
    l.state,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.transaction_status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.transaction_status = 'Failed'
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate_percentage

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY l.state

ORDER BY failure_rate_percentage DESC;



-- ============================================================
-- SECTION 10: ADVANCED MERCHANT ANALYSIS
-- ============================================================


-- 29. MERCHANTS WITH HIGH AVERAGE TRANSACTION VALUE

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value,

    ROUND(MAX(t.amount), 2)
        AS highest_transaction

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

HAVING COUNT(t.transaction_id) >= 20

ORDER BY average_transaction_value DESC;


-- 30. MERCHANTS WITH HIGH-VALUE TRANSACTIONS

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(*) FILTER (
        WHERE t.amount > 50000
    ) AS high_value_transaction_count,

    ROUND(
        SUM(
            CASE
                WHEN t.amount > 50000
                THEN t.amount
                ELSE 0
            END
        ),
        2
    ) AS high_value_transaction_amount

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

HAVING COUNT(*) FILTER (
    WHERE t.amount > 50000
) > 0

ORDER BY high_value_transaction_count DESC;


-- 31. MERCHANT FAILURE RATE

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.transaction_status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.transaction_status = 'Failed'
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate_percentage

FROM merchants AS m

JOIN transactions AS t
    ON m.merchant_id = t.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

HAVING COUNT(*) >= 20

ORDER BY failure_rate_percentage DESC;



-- ============================================================
-- SECTION 11: FRAUD INVESTIGATION CANDIDATES
-- ============================================================


-- 32. HIGH-VALUE FAILED TRANSACTIONS

SELECT
    t.transaction_id,
    t.transaction_date,
    t.account_id,
    t.transaction_type,
    t.amount,
    t.payment_method,
    t.transaction_channel,
    t.transaction_status

FROM transactions AS t

WHERE t.amount > 50000
AND t.transaction_status = 'Failed'

ORDER BY t.amount DESC;


-- 33. HIGH-VALUE TRANSACTIONS BY MERCHANT

SELECT
    t.transaction_id,

    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    t.transaction_date,
    t.amount,
    t.payment_method,
    t.transaction_status

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

WHERE t.amount > 50000

ORDER BY t.amount DESC;


-- 34. HIGH-VALUE TRANSACTIONS BY LOCATION

SELECT
    t.transaction_id,

    l.city,
    l.state,

    t.transaction_date,
    t.amount,
    t.transaction_type,
    t.payment_method,
    t.transaction_status

FROM transactions AS t

JOIN locations AS l
    ON t.location_id = l.location_id

WHERE t.amount > 50000

ORDER BY t.amount DESC;


-- 35. HIGH-VALUE TRANSACTIONS WITH CUSTOMER DETAILS

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.risk_category,

    t.transaction_id,
    t.transaction_date,
    t.amount,
    t.transaction_type,
    t.payment_method,
    t.transaction_status

FROM transactions AS t

JOIN accounts AS a
    ON t.account_id = a.account_id

JOIN customers AS c
    ON a.customer_id = c.customer_id

WHERE t.amount > 50000

ORDER BY t.amount DESC;



-- ============================================================
-- SECTION 12: MERCHANT RISK INDICATORS
-- ============================================================


-- 36. MERCHANTS WITH HIGH VALUE + FAILED TRANSACTIONS

WITH merchant_metrics AS (

    SELECT

        m.merchant_id,
        m.merchant_name,
        m.merchant_category,

        COUNT(*) AS total_transactions,

        SUM(t.amount) AS total_amount,

        AVG(t.amount) AS average_amount,

        COUNT(*) FILTER (
            WHERE t.transaction_status = 'Failed'
        ) AS failed_transactions

    FROM merchants AS m

    JOIN transactions AS t
        ON m.merchant_id = t.merchant_id

    GROUP BY
        m.merchant_id,
        m.merchant_name,
        m.merchant_category
)

SELECT

    merchant_id,
    merchant_name,
    merchant_category,

    total_transactions,

    ROUND(total_amount, 2)
        AS total_amount,

    ROUND(average_amount, 2)
        AS average_amount,

    failed_transactions,

    ROUND(
        failed_transactions * 100.0 /
        total_transactions,
        2
    ) AS failure_rate_percentage

FROM merchant_metrics

WHERE total_amount > 500000
AND failed_transactions > 0

ORDER BY failure_rate_percentage DESC;



-- ============================================================
-- SECTION 13: LOCATION RISK INDICATORS
-- ============================================================


-- 37. LOCATIONS WITH HIGH TRANSACTION VALUE

SELECT

    l.location_id,
    l.city,
    l.state,

    COUNT(t.transaction_id)
        AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value,

    ROUND(MAX(t.amount), 2)
        AS highest_transaction

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY
    l.location_id,
    l.city,
    l.state

HAVING SUM(t.amount) > 500000

ORDER BY total_transaction_value DESC;


-- 38. LOCATIONS WITH HIGH FAILURE RATE

SELECT

    l.location_id,
    l.city,
    l.state,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.transaction_status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.transaction_status = 'Failed'
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate_percentage

FROM locations AS l

JOIN transactions AS t
    ON l.location_id = t.location_id

GROUP BY
    l.location_id,
    l.city,
    l.state

HAVING COUNT(*) >= 20

ORDER BY failure_rate_percentage DESC;



-- ============================================================
-- SECTION 14: MERCHANT AND LOCATION COMBINED ANALYSIS
-- ============================================================


-- 39. TOP MERCHANT CATEGORIES BY STATE

SELECT
    l.state,
    m.merchant_category,

    COUNT(*) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value,

    ROUND(AVG(t.amount), 2)
        AS average_transaction_value

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.state,
    m.merchant_category

ORDER BY
    l.state,
    total_transaction_value DESC;


-- 40. TOP MERCHANT CATEGORIES BY CITY

SELECT
    l.city,
    l.state,
    m.merchant_category,

    COUNT(*) AS transaction_count,

    ROUND(SUM(t.amount), 2)
        AS total_transaction_value

FROM transactions AS t

JOIN merchants AS m
    ON t.merchant_id = m.merchant_id

JOIN locations AS l
    ON t.location_id = l.location_id

GROUP BY
    l.city,
    l.state,
    m.merchant_category

ORDER BY total_transaction_value DESC;


-- ============================================================
-- END OF MERCHANT & LOCATION ANALYSIS
-- ============================================================