-- =========================
-- Bottleneck Analysis
-- =========================

WITH order_delays AS (
    SELECT
        o.order_id,
        op.warehouse,
        DATEDIFF(day, o.promised_date, o.delivered_date) AS delay_days
    FROM orders o
    JOIN operations op
        ON o.order_id = op.order_id
    WHERE o.delivered_date > o.promised_date
)

SELECT
    warehouse,
    COUNT(*) AS delayed_orders,
    ROUND(AVG(delay_days), 2) AS avg_delay_days
FROM order_delays
GROUP BY warehouse
ORDER BY avg_delay_days DESC;




-- =========================
-- Pareto Analysis: Delay Reasons
-- =========================

SELECT
    delay_reason,
    COUNT(*) AS occurrences
FROM operations
WHERE delay_reason IS NOT NULL
GROUP BY delay_reason
ORDER BY occurrences DESC;




-- =========================
-- Root Cause by Warehouse
-- =========================

SELECT
    warehouse,
    delay_reason,
    COUNT(*) AS total_cases
FROM operations
WHERE delay_reason IS NOT NULL
GROUP BY warehouse, delay_reason
ORDER BY warehouse, total_cases DESC;
