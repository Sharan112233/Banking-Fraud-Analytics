-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 06_fraud_alerts.sql
-- PURPOSE: Transaction-Level Fraud Alert Detection
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: CLEAR OLD ALERTS
-- ============================================================

DELETE FROM fraud_alerts;


-- ============================================================
-- SECTION 2: ACCOUNT BEHAVIOR
-- ============================================================

WITH account_behavior AS (

    SELECT

        account_id,

        AVG(amount) AS average_amount

    FROM transactions

    GROUP BY account_id
),


-- ============================================================
-- SECTION 3: PREVIOUS TRANSACTION
-- ============================================================

transaction_sequence AS (

    SELECT

        t.*,

        LAG(transaction_date) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date
        ) AS previous_transaction_time,

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

    FROM transactions AS t
),


-- ============================================================
-- SECTION 4: RAPID TRANSACTION FLAG
-- ============================================================

rapid_transactions AS (

    SELECT

        transaction_id,

        CASE

            WHEN previous_transaction_time IS NOT NULL

                 AND transaction_date -
                     previous_transaction_time
                     <= INTERVAL '2 minutes'

            THEN 1

            ELSE 0

        END AS rapid_transaction_flag

    FROM transaction_sequence
),


-- ============================================================
-- SECTION 5: FAILED ATTEMPTS FOLLOWED BY SUCCESS
-- ============================================================

failed_success AS (

    SELECT

        transaction_id,

        CASE

            WHEN transaction_status = 'Completed'

                 AND previous_status = 'Failed'

                 AND status_two_transactions_ago = 'Failed'

                 AND status_three_transactions_ago = 'Failed'

            THEN 1

            ELSE 0

        END AS failed_success_flag

    FROM transaction_sequence
),


-- ============================================================
-- SECTION 6: MULTIPLE DEVICES WITHIN 10 MINUTES
-- ============================================================

device_velocity AS (

    SELECT

        t1.transaction_id,

        COUNT(
            DISTINCT t2.device_id
        ) AS devices_within_10_minutes

    FROM transactions AS t1

    JOIN transactions AS t2

        ON t1.account_id = t2.account_id

        AND t2.transaction_date
            BETWEEN
                t1.transaction_date
                - INTERVAL '10 minutes'

                AND

                t1.transaction_date
                + INTERVAL '10 minutes'

    GROUP BY

        t1.transaction_id
),


-- ============================================================
-- SECTION 7: MULTIPLE LOCATIONS WITHIN 10 MINUTES
-- ============================================================

location_velocity AS (

    SELECT

        t1.transaction_id,

        COUNT(
            DISTINCT t2.location_id
        ) AS locations_within_10_minutes

    FROM transactions AS t1

    JOIN transactions AS t2

        ON t1.account_id = t2.account_id

        AND t2.transaction_date
            BETWEEN
                t1.transaction_date
                - INTERVAL '10 minutes'

                AND

                t1.transaction_date
                + INTERVAL '10 minutes'

    GROUP BY

        t1.transaction_id
),


-- ============================================================
-- SECTION 8: CALCULATE FRAUD INDICATORS
-- ============================================================

risk_indicators AS (

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


        -- HIGH VALUE
        CASE

            WHEN t.amount > 150000

            THEN 1

            ELSE 0

        END AS high_value_flag,


        -- UNUSUAL AMOUNT
        CASE

            WHEN t.amount >
                 ab.average_amount * 3

            THEN 1

            ELSE 0

        END AS unusual_amount_flag,


        -- RAPID TRANSACTION
        rt.rapid_transaction_flag,


        -- FAILED ATTEMPTS FOLLOWED BY SUCCESS
        fs.failed_success_flag,


        -- MULTIPLE DEVICES IN 10 MINUTES
        CASE

            WHEN dv.devices_within_10_minutes >= 3

            THEN 1

            ELSE 0

        END AS multiple_device_flag,


        -- MULTIPLE LOCATIONS IN 10 MINUTES
        CASE

            WHEN lv.locations_within_10_minutes >= 3

            THEN 1

            ELSE 0

        END AS multiple_location_flag


    FROM transaction_sequence AS t


    JOIN account_behavior AS ab

        ON t.account_id = ab.account_id


    JOIN rapid_transactions AS rt

        ON t.transaction_id =
           rt.transaction_id


    JOIN failed_success AS fs

        ON t.transaction_id =
           fs.transaction_id


    JOIN device_velocity AS dv

        ON t.transaction_id =
           dv.transaction_id


    JOIN location_velocity AS lv

        ON t.transaction_id =
           lv.transaction_id
),


-- ============================================================
-- SECTION 9: CALCULATE RISK SCORE
-- ============================================================

risk_scored AS (

    SELECT

        *,

        (

            high_value_flag

            +

            unusual_amount_flag

            +

            rapid_transaction_flag

            +

            failed_success_flag

            +

            multiple_device_flag

            +

            multiple_location_flag

        ) AS risk_score

    FROM risk_indicators
),


-- ============================================================
-- SECTION 10: CREATE FRAUD RULE DESCRIPTION
-- ============================================================

classified_alerts AS (

    SELECT

        *,

        CASE

            WHEN high_value_flag = 1
                 AND unusual_amount_flag = 1
                 AND rapid_transaction_flag = 1
                 AND failed_success_flag = 1
                 AND multiple_device_flag = 1
                 AND multiple_location_flag = 1

                THEN 'Multiple Risk Indicators'


            WHEN high_value_flag = 1
                 AND unusual_amount_flag = 1
                 AND rapid_transaction_flag = 1

                THEN 'High Value + Unusual Amount + Rapid Transaction'


            WHEN high_value_flag = 1
                 AND unusual_amount_flag = 1
                 AND multiple_device_flag = 1

                THEN 'High Value + Unusual Amount + Multiple Devices'


            WHEN high_value_flag = 1
                 AND unusual_amount_flag = 1
                 AND multiple_location_flag = 1

                THEN 'High Value + Unusual Amount + Multiple Locations'


            WHEN rapid_transaction_flag = 1
                 AND multiple_device_flag = 1
                 AND multiple_location_flag = 1

                THEN 'Rapid Transaction + Multiple Devices + Multiple Locations'


            WHEN failed_success_flag = 1
                 AND high_value_flag = 1

                THEN 'Failed Attempts Followed By High Value Success'


            WHEN multiple_device_flag = 1
                 AND multiple_location_flag = 1

                THEN 'Multiple Devices + Multiple Locations Within 10 Minutes'


            WHEN unusual_amount_flag = 1
                 AND rapid_transaction_flag = 1

                THEN 'Unusual Amount + Rapid Transaction'


            WHEN high_value_flag = 1
                 AND rapid_transaction_flag = 1

                THEN 'High Value + Rapid Transaction'


            WHEN failed_success_flag = 1

                THEN 'Multiple Failed Attempts Followed By Success'


            WHEN multiple_device_flag = 1

                THEN 'Multiple Devices Within 10 Minutes'


            WHEN multiple_location_flag = 1

                THEN 'Multiple Locations Within 10 Minutes'


            WHEN unusual_amount_flag = 1

                THEN 'Unusual Transaction Amount'


            WHEN high_value_flag = 1

                THEN 'High Transaction Value'


            WHEN rapid_transaction_flag = 1

                THEN 'Rapid Transactions'


            ELSE 'Other'

        END AS fraud_rule

    FROM risk_scored
),


-- ============================================================
-- SECTION 11: GENERATE ALERT IDs
-- ============================================================

final_alerts AS (

    SELECT

        'AL' ||

        LPAD(

            ROW_NUMBER() OVER (

                ORDER BY

                    risk_score DESC,

                    transaction_date,

                    transaction_id

            )::TEXT,

            28,

            '0'

        ) AS alert_id,


        transaction_id,

        fraud_rule,

        risk_score

    FROM classified_alerts

    WHERE risk_score >= 2
)


-- ============================================================
-- SECTION 12: INSERT FRAUD ALERTS
-- ============================================================

INSERT INTO fraud_alerts (

    alert_id,

    transaction_id,

    fraud_rule,

    risk_score,

    alert_status

)

SELECT

    alert_id,

    transaction_id,

    fraud_rule,

    risk_score,

    'Open'

FROM final_alerts;



-- ============================================================
-- SECTION 13: ALERT COUNT
-- ============================================================

SELECT

    COUNT(*) AS total_fraud_alerts

FROM fraud_alerts;



-- ============================================================
-- SECTION 14: ALERTS BY RISK SCORE
-- ============================================================

SELECT

    risk_score,

    COUNT(*) AS alert_count

FROM fraud_alerts

GROUP BY risk_score

ORDER BY risk_score DESC;



-- ============================================================
-- SECTION 15: ALERTS BY FRAUD RULE
-- ============================================================

SELECT

    fraud_rule,

    COUNT(*) AS alert_count

FROM fraud_alerts

GROUP BY fraud_rule

ORDER BY alert_count DESC;



-- ============================================================
-- SECTION 16: ALERT RATE
-- ============================================================

SELECT

    COUNT(fa.alert_id)
        AS total_alerts,

    COUNT(t.transaction_id)
        AS total_transactions,

    ROUND(

        COUNT(fa.alert_id) * 100.0
        /
        NULLIF(
            COUNT(t.transaction_id),
            0
        ),

        2

    ) AS fraud_alert_rate_percentage

FROM transactions AS t

LEFT JOIN fraud_alerts AS fa

    ON t.transaction_id =
       fa.transaction_id;



-- ============================================================
-- SECTION 17: HIGH-RISK ALERTS
-- ============================================================

SELECT

    fa.alert_id,

    fa.transaction_id,

    t.account_id,

    t.transaction_date,

    ROUND(
        t.amount,
        2
    ) AS amount,

    fa.fraud_rule,

    fa.risk_score,

    fa.alert_status

FROM fraud_alerts AS fa

JOIN transactions AS t

    ON fa.transaction_id =
       t.transaction_id

WHERE fa.risk_score >= 3

ORDER BY

    fa.risk_score DESC,

    t.amount DESC

LIMIT 100;



-- ============================================================
-- SECTION 18: FULL ALERT DETAILS
-- ============================================================

SELECT

    fa.alert_id,

    fa.transaction_id,

    t.account_id,

    t.transaction_date,

    ROUND(
        t.amount,
        2
    ) AS amount,

    t.transaction_type,

    t.payment_method,

    t.transaction_status,

    t.merchant_id,

    t.location_id,

    t.device_id,

    t.transaction_channel,

    fa.fraud_rule,

    fa.risk_score,

    fa.alert_status,

    fa.created_at

FROM fraud_alerts AS fa

JOIN transactions AS t

    ON fa.transaction_id =
       t.transaction_id

ORDER BY

    fa.risk_score DESC,

    t.amount DESC;



-- ============================================================
-- END OF FRAUD ALERT DETECTION
-- ============================================================