-- =========================
-- Operational KPIs
-- =========================

-- 1. On-Time Delivery (OTD %)
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivered_date <= promised_date THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS on_time_delivery_pct
FROM orders
WHERE delivered_date IS NOT NULL;





-- 2. SLA Compliance by Warehouse
SELECT
    op.warehouse,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.delivered_date <= o.promised_date THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS sla_compliance_pct
FROM orders o
JOIN operations op
    ON o.order_id = op.order_id
WHERE o.delivered_date IS NOT NULL
GROUP BY op.warehouse
ORDER BY sla_compliance_pct ASC;




-- 3. Average Lead Time (days)
SELECT
    ROUND(
        AVG(DATEDIFF(day, order_date, delivered_date)),
        2
    ) AS avg_lead_time_days
FROM orders
WHERE delivered_date IS NOT NULL;




-- 4. Delayed Orders Count
SELECT
    COUNT(*) AS delayed_orders
FROM orders
WHERE delivered_date > promised_date;
