-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 05_fraud_detection.sql
-- PURPOSE: Detect suspicious transaction patterns
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: HIGH-VALUE TRANSACTION DETECTION
-- ============================================================

-- Rule:
-- Transactions above 150,000 are considered suspicious.

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type,
    payment_method,
    transaction_status,
    device_id,
    transaction_channel
FROM transactions
WHERE amount > 150000
ORDER BY amount DESC;


-- ============================================================
-- SECTION 2: HIGH-VALUE TRANSACTION SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS suspicious_transaction_count,

    ROUND(SUM(amount), 2)
        AS total_suspicious_amount,

    ROUND(AVG(amount), 2)
        AS average_suspicious_amount,

    ROUND(MAX(amount), 2)
        AS highest_transaction

FROM transactions

WHERE amount > 150000;



-- ============================================================
-- SECTION 3: HIGH-VALUE TRANSACTIONS BY ACCOUNT
-- ============================================================

SELECT
    account_id,

    COUNT(*) AS suspicious_transaction_count,

    ROUND(SUM(amount), 2)
        AS total_suspicious_amount,

    ROUND(AVG(amount), 2)
        AS average_transaction_amount,

    ROUND(MAX(amount), 2)
        AS highest_transaction

FROM transactions

WHERE amount > 150000

GROUP BY account_id

ORDER BY suspicious_transaction_count DESC;



-- ============================================================
-- SECTION 4: RAPID TRANSACTION DETECTION
-- ============================================================

-- Rule:
-- Detect transactions made within 2 minutes
-- of another transaction from the same account.

WITH transaction_sequence AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date,
        amount,
        transaction_type,
        payment_method,
        transaction_status,
        device_id,
        transaction_channel,

        LAG(transaction_date) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_transaction_time

    FROM transactions
)

SELECT
    transaction_id,
    account_id,
    transaction_date,
    previous_transaction_time,
    amount,

    ROUND(
        EXTRACT(
            EPOCH FROM (
                transaction_date -
                previous_transaction_time
            )
        ) / 60.0,
        2
    ) AS minutes_since_previous_transaction

FROM transaction_sequence

WHERE previous_transaction_time IS NOT NULL

AND transaction_date -
    previous_transaction_time
    <= INTERVAL '2 minutes'

ORDER BY
    account_id,
    transaction_date;



-- ============================================================
-- SECTION 5: RAPID TRANSACTION SUMMARY BY ACCOUNT
-- ============================================================

WITH transaction_sequence AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date,

        LAG(transaction_date) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_transaction_time

    FROM transactions

),

rapid_transactions AS (

    SELECT
        transaction_id,
        account_id,
        transaction_date

    FROM transaction_sequence

    WHERE previous_transaction_time IS NOT NULL

    AND transaction_date -
        previous_transaction_time
        <= INTERVAL '2 minutes'
)

SELECT
    account_id,

    COUNT(*) AS rapid_transaction_count,

    MIN(transaction_date)
        AS first_rapid_transaction,

    MAX(transaction_date)
        AS last_rapid_transaction

FROM rapid_transactions

GROUP BY account_id

ORDER BY rapid_transaction_count DESC;



-- ============================================================
-- SECTION 6: MULTIPLE DEVICE DETECTION
-- ============================================================

-- Rule:
-- Accounts using 3 or more different devices
-- are considered suspicious.

SELECT
    account_id,

    COUNT(DISTINCT device_id)
        AS unique_devices,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2)
        AS total_transaction_amount

FROM transactions

GROUP BY account_id

HAVING COUNT(DISTINCT device_id) >= 3

ORDER BY unique_devices DESC;



-- ============================================================
-- SECTION 7: MULTIPLE LOCATION DETECTION
-- ============================================================

-- Rule:
-- Accounts transacting from 3 or more locations
-- are considered suspicious.

SELECT
    account_id,

    COUNT(DISTINCT location_id)
        AS unique_locations,

    COUNT(*) AS transaction_count,

    ROUND(SUM(amount), 2)
        AS total_transaction_amount

FROM transactions

GROUP BY account_id

HAVING COUNT(DISTINCT location_id) >= 3

ORDER BY unique_locations DESC;



-- ============================================================
-- SECTION 8: FAILED ATTEMPTS FOLLOWED BY SUCCESS
-- ============================================================

-- Rule:
-- Detect the pattern:
--
-- Failed
-- Failed
-- Failed
-- Completed
--
-- for the same account.

WITH transaction_sequence AS (

    SELECT

        transaction_id,
        account_id,
        transaction_date,
        amount,
        transaction_status,

        LAG(transaction_status, 1) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_status,

        LAG(transaction_status, 2) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS status_two_transactions_ago,

        LAG(transaction_status, 3) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS status_three_transactions_ago

    FROM transactions
)

SELECT

    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_status,
    previous_status,
    status_two_transactions_ago,
    status_three_transactions_ago

FROM transaction_sequence

WHERE transaction_status = 'Completed'

AND previous_status = 'Failed'

AND status_two_transactions_ago = 'Failed'

AND status_three_transactions_ago = 'Failed'

ORDER BY transaction_date;



-- ============================================================
-- SECTION 9: FAILED ATTEMPTS FOLLOWED BY SUCCESS SUMMARY
-- ============================================================

WITH transaction_sequence AS (

    SELECT

        transaction_id,
        account_id,
        transaction_date,
        transaction_status,

        LAG(transaction_status, 1) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_status,

        LAG(transaction_status, 2) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS status_two_transactions_ago,

        LAG(transaction_status, 3) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS status_three_transactions_ago

    FROM transactions
)

SELECT

    account_id,

    COUNT(*) AS suspicious_success_count

FROM transaction_sequence

WHERE transaction_status = 'Completed'

AND previous_status = 'Failed'

AND status_two_transactions_ago = 'Failed'

AND status_three_transactions_ago = 'Failed'

GROUP BY account_id

ORDER BY suspicious_success_count DESC;



-- ============================================================
-- SECTION 10: ACCOUNT BEHAVIORAL BASELINE
-- ============================================================

-- Calculate normal transaction behavior for each account.

SELECT

    account_id,

    COUNT(*) AS transaction_count,

    ROUND(AVG(amount), 2)
        AS average_transaction_amount,

    ROUND(STDDEV(amount), 2)
        AS transaction_stddev,

    ROUND(MIN(amount), 2)
        AS minimum_transaction,

    ROUND(MAX(amount), 2)
        AS maximum_transaction

FROM transactions

GROUP BY account_id

ORDER BY average_transaction_amount DESC;



-- ============================================================
-- SECTION 11: TRANSACTIONS 3X ABOVE ACCOUNT AVERAGE
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_transaction_amount

    FROM transactions

    GROUP BY account_id
)

SELECT

    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    ROUND(
        ab.average_transaction_amount,
        2
    ) AS account_average_amount,

    ROUND(
        t.amount /
        NULLIF(
            ab.average_transaction_amount,
            0
        ),
        2
    ) AS amount_vs_average_ratio

FROM transactions AS t

JOIN account_behavior AS ab

    ON t.account_id = ab.account_id

WHERE t.amount >
      ab.average_transaction_amount * 3

ORDER BY amount_vs_average_ratio DESC;



-- ============================================================
-- SECTION 12: TRANSACTIONS ABOVE ACCOUNT STANDARD DEVIATION
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount,

        STDDEV(amount)
            AS standard_deviation

    FROM transactions

    GROUP BY account_id
)

SELECT

    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    ROUND(
        ab.average_amount,
        2
    ) AS account_average_amount,

    ROUND(
        ab.standard_deviation,
        2
    ) AS account_standard_deviation,

    ROUND(
        (
            t.amount -
            ab.average_amount
        )
        /
        NULLIF(
            ab.standard_deviation,
            0
        ),
        2
    ) AS transaction_z_score

FROM transactions AS t

JOIN account_behavior AS ab

    ON t.account_id = ab.account_id

WHERE ab.standard_deviation > 0

AND (
    t.amount -
    ab.average_amount
)
/
NULLIF(
    ab.standard_deviation,
    0
) > 3

ORDER BY transaction_z_score DESC;



-- ============================================================
-- SECTION 13: HIGH-VALUE + MULTIPLE DEVICE INDICATOR
-- ============================================================

WITH account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
)

SELECT

    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    ad.unique_devices,

    t.device_id

FROM transactions AS t

JOIN account_devices AS ad

    ON t.account_id = ad.account_id

WHERE t.amount > 150000

AND ad.unique_devices >= 3

ORDER BY t.amount DESC;



-- ============================================================
-- SECTION 14: HIGH-VALUE + MULTIPLE LOCATION INDICATOR
-- ============================================================

WITH account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
)

SELECT

    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,

    al.unique_locations,

    t.location_id

FROM transactions AS t

JOIN account_locations AS al

    ON t.account_id = al.account_id

WHERE t.amount > 150000

AND al.unique_locations >= 3

ORDER BY t.amount DESC;



-- ============================================================
-- SECTION 15: COMBINED FRAUD RISK SCORE
-- ============================================================

-- Risk indicators:
--
-- 1 point = transaction above 150,000
-- 1 point = transaction 3X above account average
-- 1 point = account uses 3+ devices
-- 1 point = account uses 3+ locations
--
-- Maximum score = 4


WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount

    FROM transactions

    GROUP BY account_id
),

account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
),

account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
)

SELECT

    t.transaction_id,
    t.account_id,
    t.transaction_date,
    t.amount,
    t.transaction_type,
    t.payment_method,
    t.transaction_status,
    t.device_id,
    t.location_id,
    t.transaction_channel,

    CASE
        WHEN t.amount > 150000
        THEN 1
        ELSE 0
    END AS high_value_flag,

    CASE
        WHEN t.amount >
             ab.average_amount * 3
        THEN 1
        ELSE 0
    END AS unusual_amount_flag,

    CASE
        WHEN ad.unique_devices >= 3
        THEN 1
        ELSE 0
    END AS multiple_device_flag,

    CASE
        WHEN al.unique_locations >= 3
        THEN 1
        ELSE 0
    END AS multiple_location_flag,

    (
        CASE
            WHEN t.amount > 150000
            THEN 1
            ELSE 0
        END

        +

        CASE
            WHEN t.amount >
                 ab.average_amount * 3
            THEN 1
            ELSE 0
        END

        +

        CASE
            WHEN ad.unique_devices >= 3
            THEN 1
            ELSE 0
        END

        +

        CASE
            WHEN al.unique_locations >= 3
            THEN 1
            ELSE 0
        END
    ) AS fraud_risk_score

FROM transactions AS t

JOIN account_behavior AS ab
    ON t.account_id = ab.account_id

JOIN account_devices AS ad
    ON t.account_id = ad.account_id

JOIN account_locations AS al
    ON t.account_id = al.account_id

ORDER BY fraud_risk_score DESC;



-- ============================================================
-- SECTION 16: RISK LEVEL CLASSIFICATION
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount

    FROM transactions

    GROUP BY account_id
),

account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
),

account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
),

risk_scoring AS (

    SELECT

        t.transaction_id,
        t.account_id,
        t.transaction_date,
        t.amount,
        t.transaction_type,
        t.payment_method,
        t.transaction_status,
        t.device_id,
        t.location_id,
        t.transaction_channel,

        (
            CASE
                WHEN t.amount > 150000
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN t.amount >
                     ab.average_amount * 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN ad.unique_devices >= 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN al.unique_locations >= 3
                THEN 1
                ELSE 0
            END
        ) AS fraud_risk_score

    FROM transactions AS t

    JOIN account_behavior AS ab
        ON t.account_id = ab.account_id

    JOIN account_devices AS ad
        ON t.account_id = ad.account_id

    JOIN account_locations AS al
        ON t.account_id = al.account_id
)

SELECT

    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type,
    payment_method,
    transaction_status,
    device_id,
    location_id,
    transaction_channel,
    fraud_risk_score,

    CASE

        WHEN fraud_risk_score >= 4
            THEN 'Critical'

        WHEN fraud_risk_score = 3
            THEN 'High'

        WHEN fraud_risk_score = 2
            THEN 'Medium'

        WHEN fraud_risk_score = 1
            THEN 'Low'

        ELSE 'Normal'

    END AS risk_level

FROM risk_scoring

ORDER BY
    fraud_risk_score DESC,
    amount DESC;



-- ============================================================
-- SECTION 17: FINAL HIGH-RISK TRANSACTIONS
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount

    FROM transactions

    GROUP BY account_id
),

account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
),

account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
),

risk_scoring AS (

    SELECT

        t.transaction_id,
        t.account_id,
        t.transaction_date,
        t.amount,
        t.transaction_type,
        t.payment_method,
        t.transaction_status,
        t.device_id,
        t.location_id,
        t.transaction_channel,

        (
            CASE
                WHEN t.amount > 150000
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN t.amount >
                     ab.average_amount * 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN ad.unique_devices >= 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN al.unique_locations >= 3
                THEN 1
                ELSE 0
            END
        ) AS fraud_risk_score

    FROM transactions AS t

    JOIN account_behavior AS ab
        ON t.account_id = ab.account_id

    JOIN account_devices AS ad
        ON t.account_id = ad.account_id

    JOIN account_locations AS al
        ON t.account_id = al.account_id
)

SELECT

    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_type,
    payment_method,
    transaction_status,
    device_id,
    location_id,
    transaction_channel,
    fraud_risk_score,

    CASE

        WHEN fraud_risk_score >= 4
            THEN 'Critical'

        WHEN fraud_risk_score = 3
            THEN 'High'

        WHEN fraud_risk_score = 2
            THEN 'Medium'

        ELSE 'Low'

    END AS risk_level

FROM risk_scoring

WHERE fraud_risk_score >= 2

ORDER BY
    fraud_risk_score DESC,
    amount DESC;



-- ============================================================
-- SECTION 18: FRAUD RISK SUMMARY
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount

    FROM transactions

    GROUP BY account_id
),

account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
),

account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
),

risk_scoring AS (

    SELECT

        t.transaction_id,

        (
            CASE
                WHEN t.amount > 150000
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN t.amount >
                     ab.average_amount * 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN ad.unique_devices >= 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN al.unique_locations >= 3
                THEN 1
                ELSE 0
            END
        ) AS fraud_risk_score

    FROM transactions AS t

    JOIN account_behavior AS ab
        ON t.account_id = ab.account_id

    JOIN account_devices AS ad
        ON t.account_id = ad.account_id

    JOIN account_locations AS al
        ON t.account_id = al.account_id
)

SELECT

    fraud_risk_score,

    COUNT(*) AS transaction_count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM risk_scoring

GROUP BY fraud_risk_score

ORDER BY fraud_risk_score DESC;



-- ============================================================
-- SECTION 19: HIGH-RISK TRANSACTIONS BY ACCOUNT
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount)
            AS average_amount

    FROM transactions

    GROUP BY account_id
),

account_devices AS (

    SELECT

        account_id,

        COUNT(DISTINCT device_id)
            AS unique_devices

    FROM transactions

    GROUP BY account_id
),

account_locations AS (

    SELECT

        account_id,

        COUNT(DISTINCT location_id)
            AS unique_locations

    FROM transactions

    GROUP BY account_id
),

risk_scoring AS (

    SELECT

        t.transaction_id,
        t.account_id,
        t.amount,

        (
            CASE
                WHEN t.amount > 150000
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN t.amount >
                     ab.average_amount * 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN ad.unique_devices >= 3
                THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN al.unique_locations >= 3
                THEN 1
                ELSE 0
            END
        ) AS fraud_risk_score

    FROM transactions AS t

    JOIN account_behavior AS ab
        ON t.account_id = ab.account_id

    JOIN account_devices AS ad
        ON t.account_id = ad.account_id

    JOIN account_locations AS al
        ON t.account_id = al.account_id
)

SELECT

    account_id,

    COUNT(*) FILTER (
        WHERE fraud_risk_score >= 2
    ) AS suspicious_transactions,

    ROUND(
        SUM(amount) FILTER (
            WHERE fraud_risk_score >= 2
        ),
        2
    ) AS suspicious_transaction_value,

    MAX(fraud_risk_score)
        AS highest_risk_score

FROM risk_scoring

GROUP BY account_id

HAVING COUNT(*) FILTER (
    WHERE fraud_risk_score >= 2
) > 0

ORDER BY
    suspicious_transactions DESC,
    suspicious_transaction_value DESC;



-- ============================================================
-- END OF FRAUD DETECTION
-- ============================================================