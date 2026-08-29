-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 08_reporting_views.sql
-- PURPOSE: Create reporting views for Power BI
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: TRANSACTION SUMMARY VIEW
-- ============================================================

DROP VIEW IF EXISTS vw_transaction_summary;

CREATE VIEW vw_transaction_summary AS

SELECT

    t.transaction_id,

    t.account_id,

    t.transaction_date,

    DATE(t.transaction_date)
        AS transaction_day,

    EXTRACT(
        YEAR FROM t.transaction_date
    )::INTEGER AS transaction_year,

    EXTRACT(
        MONTH FROM t.transaction_date
    )::INTEGER AS transaction_month,

    t.transaction_type,

    t.amount,

    t.merchant_id,

    t.location_id,

    t.payment_method,

    t.transaction_status,

    t.device_id,

    t.transaction_channel,

    CASE
        WHEN t.amount > 150000
        THEN 'High Value'

        WHEN t.amount > 50000
        THEN 'Medium Value'

        ELSE 'Normal Value'

    END AS transaction_value_category

FROM transactions AS t;



-- ============================================================
-- SECTION 2: FRAUD ALERT REPORTING VIEW
-- ============================================================

DROP VIEW IF EXISTS vw_fraud_alerts;

CREATE VIEW vw_fraud_alerts AS

SELECT

    fa.alert_id,

    fa.transaction_id,

    fa.fraud_rule,

    fa.risk_score,

    CASE

        WHEN fa.risk_score = 4
            THEN 'Critical'

        WHEN fa.risk_score = 3
            THEN 'High'

        WHEN fa.risk_score = 2
            THEN 'Medium'

        WHEN fa.risk_score = 1
            THEN 'Low'

        ELSE 'Normal'

    END AS risk_level,

    fa.alert_status,

    fa.created_at,

    t.account_id,

    t.transaction_date,

    t.amount,

    t.transaction_type,

    t.payment_method,

    t.transaction_status,

    t.merchant_id,

    t.location_id,

    t.device_id,

    t.transaction_channel

FROM fraud_alerts AS fa

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id;



-- ============================================================
-- SECTION 3: FRAUD CASE REPORTING VIEW
-- ============================================================

DROP VIEW IF EXISTS vw_fraud_cases;

CREATE VIEW vw_fraud_cases AS

SELECT

    fc.case_id,

    fc.alert_id,

    fc.investigation_date,

    fc.investigation_result,

    fc.loss_amount,

    fc.recovery_amount,

    (
        fc.loss_amount -
        fc.recovery_amount
    ) AS net_loss,

    fa.transaction_id,

    fa.fraud_rule,

    fa.risk_score,

    CASE

        WHEN fa.risk_score = 4
            THEN 'Critical'

        WHEN fa.risk_score = 3
            THEN 'High'

        WHEN fa.risk_score = 2
            THEN 'Medium'

        WHEN fa.risk_score = 1
            THEN 'Low'

        ELSE 'Normal'

    END AS risk_level,

    fa.alert_status,

    t.account_id,

    t.transaction_date,

    t.amount,

    t.transaction_type,

    t.payment_method,

    t.transaction_status,

    t.merchant_id,

    t.location_id,

    t.device_id,

    t.transaction_channel

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id;



-- ============================================================
-- SECTION 4: ACCOUNT FRAUD SUMMARY VIEW
-- ============================================================

DROP VIEW IF EXISTS vw_account_fraud_summary;

CREATE VIEW vw_account_fraud_summary AS

SELECT

    t.account_id,

    COUNT(t.transaction_id)
        AS total_transactions,

    ROUND(
        SUM(t.amount),
        2
    ) AS total_transaction_value,

    ROUND(
        AVG(t.amount),
        2
    ) AS average_transaction_value,

    COUNT(fa.alert_id)
        AS fraud_alert_count,

    COUNT(fc.case_id)
        AS fraud_case_count,

    COALESCE(
        SUM(fc.loss_amount),
        0
    ) AS total_loss,

    COALESCE(
        SUM(fc.recovery_amount),
        0
    ) AS total_recovery,

    COALESCE(
        SUM(fc.loss_amount),
        0
    )
    -
    COALESCE(
        SUM(fc.recovery_amount),
        0
    ) AS net_loss,

    MAX(fa.risk_score)
        AS highest_risk_score

FROM transactions AS t

LEFT JOIN fraud_alerts AS fa

    ON t.transaction_id =
       fa.transaction_id

LEFT JOIN fraud_cases AS fc

    ON fa.alert_id =
       fc.alert_id

GROUP BY

    t.account_id;



-- ============================================================
-- SECTION 5: VERIFY TRANSACTION VIEW
-- ============================================================

SELECT *

FROM vw_transaction_summary

LIMIT 10;



-- ============================================================
-- SECTION 6: VERIFY FRAUD ALERT VIEW
-- ============================================================

SELECT *

FROM vw_fraud_alerts

ORDER BY risk_score DESC

LIMIT 10;



-- ============================================================
-- SECTION 7: VERIFY FRAUD CASE VIEW
-- ============================================================

SELECT *

FROM vw_fraud_cases

ORDER BY risk_score DESC

LIMIT 10;



-- ============================================================
-- SECTION 8: VERIFY ACCOUNT SUMMARY
-- ============================================================

SELECT *

FROM vw_account_fraud_summary

ORDER BY highest_risk_score DESC

LIMIT 20;



-- ============================================================
-- SECTION 9: REPORTING VIEW SUMMARY
-- ============================================================

SELECT

    'vw_transaction_summary'
        AS view_name,

    COUNT(*)
        AS row_count

FROM vw_transaction_summary

UNION ALL

SELECT

    'vw_fraud_alerts',

    COUNT(*)

FROM vw_fraud_alerts

UNION ALL

SELECT

    'vw_fraud_cases',

    COUNT(*)

FROM vw_fraud_cases

UNION ALL

SELECT

    'vw_account_fraud_summary',

    COUNT(*)

FROM vw_account_fraud_summary;



-- ============================================================
-- END OF REPORTING VIEWS
-- ============================================================