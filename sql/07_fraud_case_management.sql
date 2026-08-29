-- ============================================================
-- BANKING TRANSACTION & FRAUD ANALYTICS
-- FILE: 07_fraud_case_management.sql
-- PURPOSE: Fraud Case Management & Investigation Analysis
-- DATABASE: PostgreSQL
-- ============================================================


-- ============================================================
-- SECTION 1: CREATE FRAUD CASES FROM HIGH-RISK ALERTS
-- ============================================================

-- Only create cases for alerts that do not already have
-- a corresponding fraud case.

INSERT INTO fraud_cases (
    case_id,
    alert_id,
    investigation_date,
    investigation_result,
    loss_amount,
    recovery_amount
)

SELECT

    'CASE' ||
    LPAD(
        ROW_NUMBER() OVER (
            ORDER BY
                fa.risk_score DESC,
                fa.created_at,
                fa.alert_id
        )::TEXT,
        26,
        '0'
    ) AS case_id,

    fa.alert_id,

    CURRENT_DATE AS investigation_date,

    'Pending Investigation' AS investigation_result,

    0.00 AS loss_amount,

    0.00 AS recovery_amount

FROM fraud_alerts AS fa

WHERE fa.risk_score >= 3

AND NOT EXISTS (

    SELECT 1

    FROM fraud_cases AS fc

    WHERE fc.alert_id = fa.alert_id
);



-- ============================================================
-- SECTION 2: TOTAL FRAUD CASES
-- ============================================================

SELECT

    COUNT(*) AS total_fraud_cases

FROM fraud_cases;



-- ============================================================
-- SECTION 3: CASES BY INVESTIGATION RESULT
-- ============================================================

SELECT

    investigation_result,

    COUNT(*) AS case_count,

    ROUND(
        SUM(loss_amount),
        2
    ) AS total_loss_amount,

    ROUND(
        SUM(recovery_amount),
        2
    ) AS total_recovery_amount

FROM fraud_cases

GROUP BY investigation_result

ORDER BY case_count DESC;



-- ============================================================
-- SECTION 4: FRAUD CASE DETAILS
-- ============================================================

SELECT

    fc.case_id,

    fc.alert_id,

    fc.investigation_date,

    fc.investigation_result,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount,

    fa.transaction_id,

    fa.fraud_rule,

    fa.risk_score,

    fa.alert_status

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

ORDER BY

    fa.risk_score DESC,

    fc.investigation_date DESC;



-- ============================================================
-- SECTION 5: CASES WITH TRANSACTION DETAILS
-- ============================================================

SELECT

    fc.case_id,

    fc.alert_id,

    fc.investigation_date,

    fc.investigation_result,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount,

    t.transaction_id,

    t.account_id,

    t.transaction_date,

    ROUND(
        t.amount,
        2
    ) AS transaction_amount,

    t.transaction_type,

    t.payment_method,

    t.transaction_status,

    t.device_id,

    t.location_id,

    t.transaction_channel,

    fa.fraud_rule,

    fa.risk_score

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id

ORDER BY

    fa.risk_score DESC,

    t.amount DESC;



-- ============================================================
-- SECTION 6: HIGH-RISK CASES
-- ============================================================

SELECT

    fc.case_id,

    fc.alert_id,

    fa.transaction_id,

    fa.risk_score,

    fa.fraud_rule,

    fc.investigation_date,

    fc.investigation_result,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

WHERE fa.risk_score >= 3

ORDER BY

    fa.risk_score DESC,

    fc.investigation_date DESC;



-- ============================================================
-- SECTION 7: PENDING INVESTIGATIONS
-- ============================================================

SELECT

    fc.case_id,

    fc.alert_id,

    fa.transaction_id,

    fa.fraud_rule,

    fa.risk_score,

    fc.investigation_date,

    fc.investigation_result

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

WHERE fc.investigation_result =
      'Pending Investigation'

ORDER BY

    fa.risk_score DESC,

    fc.investigation_date;



-- ============================================================
-- SECTION 8: CASES WITH FINANCIAL LOSS
-- ============================================================

SELECT

    fc.case_id,

    fc.alert_id,

    fa.transaction_id,

    fa.risk_score,

    fa.fraud_rule,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

WHERE fc.loss_amount > 0

ORDER BY fc.loss_amount DESC;



-- ============================================================
-- SECTION 9: RECOVERY ANALYSIS
-- ============================================================

SELECT

    COUNT(*) AS cases_with_recovery,

    ROUND(
        SUM(recovery_amount),
        2
    ) AS total_recovered_amount,

    ROUND(
        AVG(recovery_amount),
        2
    ) AS average_recovered_amount

FROM fraud_cases

WHERE recovery_amount > 0;



-- ============================================================
-- SECTION 10: LOSS ANALYSIS
-- ============================================================

SELECT

    COUNT(*) AS cases_with_loss,

    ROUND(
        SUM(loss_amount),
        2
    ) AS total_loss_amount,

    ROUND(
        AVG(loss_amount),
        2
    ) AS average_loss_amount,

    ROUND(
        MAX(loss_amount),
        2
    ) AS highest_loss_amount

FROM fraud_cases

WHERE loss_amount > 0;



-- ============================================================
-- SECTION 11: NET FINANCIAL IMPACT
-- ============================================================

SELECT

    ROUND(
        SUM(loss_amount),
        2
    ) AS total_loss,

    ROUND(
        SUM(recovery_amount),
        2
    ) AS total_recovery,

    ROUND(
        SUM(loss_amount)
        - SUM(recovery_amount),
        2
    ) AS net_loss

FROM fraud_cases;



-- ============================================================
-- SECTION 12: RECOVERY RATE
-- ============================================================

SELECT

    ROUND(
        SUM(recovery_amount),
        2
    ) AS total_recovery,

    ROUND(
        SUM(loss_amount),
        2
    ) AS total_loss,

    CASE

        WHEN SUM(loss_amount) > 0

        THEN ROUND(
            SUM(recovery_amount)
            * 100.0
            / SUM(loss_amount),
            2
        )

        ELSE 0

    END AS recovery_rate_percentage

FROM fraud_cases;



-- ============================================================
-- SECTION 13: CASES BY FRAUD RULE
-- ============================================================

SELECT

    fa.fraud_rule,

    COUNT(fc.case_id)
        AS case_count,

    ROUND(
        SUM(fc.loss_amount),
        2
    ) AS total_loss,

    ROUND(
        SUM(fc.recovery_amount),
        2
    ) AS total_recovery

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

GROUP BY fa.fraud_rule

ORDER BY case_count DESC;



-- ============================================================
-- SECTION 14: CASES BY RISK SCORE
-- ============================================================

SELECT

    fa.risk_score,

    COUNT(fc.case_id)
        AS case_count,

    ROUND(
        SUM(fc.loss_amount),
        2
    ) AS total_loss,

    ROUND(
        SUM(fc.recovery_amount),
        2
    ) AS total_recovery

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

GROUP BY fa.risk_score

ORDER BY fa.risk_score DESC;



-- ============================================================
-- SECTION 15: CASES BY ACCOUNT
-- ============================================================

SELECT

    t.account_id,

    COUNT(DISTINCT fc.case_id)
        AS fraud_case_count,

    ROUND(
        SUM(fc.loss_amount),
        2
    ) AS total_loss,

    ROUND(
        SUM(fc.recovery_amount),
        2
    ) AS total_recovery,

    MAX(fa.risk_score)
        AS highest_risk_score

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id

GROUP BY t.account_id

ORDER BY

    highest_risk_score DESC,

    total_loss DESC;



-- ============================================================
-- SECTION 16: TOP TRANSACTIONS INVOLVED IN FRAUD CASES
-- ============================================================

SELECT

    fc.case_id,

    t.transaction_id,

    t.account_id,

    t.transaction_date,

    ROUND(
        t.amount,
        2
    ) AS transaction_amount,

    fa.fraud_rule,

    fa.risk_score,

    fc.investigation_result,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id

ORDER BY

    t.amount DESC

LIMIT 20;



-- ============================================================
-- SECTION 17: FRAUD CASE DASHBOARD SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT fc.case_id)
        AS total_cases,

    COUNT(DISTINCT t.account_id)
        AS affected_accounts,

    COUNT(DISTINCT fa.transaction_id)
        AS suspicious_transactions,

    ROUND(
        SUM(fc.loss_amount),
        2
    ) AS total_loss,

    ROUND(
        SUM(fc.recovery_amount),
        2
    ) AS total_recovery,

    ROUND(
        SUM(fc.loss_amount)
        - SUM(fc.recovery_amount),
        2
    ) AS net_loss,

    COUNT(*) FILTER (
        WHERE fc.investigation_result =
              'Pending Investigation'
    ) AS pending_cases

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id;



-- ============================================================
-- SECTION 18: FULL FRAUD INVESTIGATION VIEW
-- ============================================================

SELECT

    fc.case_id,

    fc.investigation_date,

    fc.investigation_result,

    ROUND(
        fc.loss_amount,
        2
    ) AS loss_amount,

    ROUND(
        fc.recovery_amount,
        2
    ) AS recovery_amount,

    fa.alert_id,

    fa.fraud_rule,

    fa.risk_score,

    fa.alert_status,

    t.transaction_id,

    t.account_id,

    t.transaction_date,

    ROUND(
        t.amount,
        2
    ) AS transaction_amount,

    t.transaction_type,

    t.payment_method,

    t.transaction_status,

    t.device_id,

    t.location_id,

    t.transaction_channel

FROM fraud_cases AS fc

JOIN fraud_alerts AS fa

    ON fc.alert_id = fa.alert_id

JOIN transactions AS t

    ON fa.transaction_id = t.transaction_id

ORDER BY

    fa.risk_score DESC,

    t.amount DESC;



-- ============================================================
-- END OF FRAUD CASE MANAGEMENT
-- ============================================================