-- =========================
-- 02_kpis.sql
-- Operational + Delivery KPIs
-- =========================

-- -------------------------------------------------
-- 1) Orders overview (volume + completion)
-- -------------------------------------------------
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE WHEN delivered_date IS NOT NULL THEN 1 ELSE 0 END) AS delivered_orders,
  SUM(CASE WHEN delivered_date IS NULL THEN 1 ELSE 0 END) AS open_orders,
  ROUND(
    SUM(CASE WHEN delivered_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) AS delivered_rate_pct
FROM orders;


-- -------------------------------------------------
-- 2) On-time performance (delivered orders only)
-- -------------------------------------------------
SELECT
  COUNT(*) AS delivered_orders,
  SUM(CASE WHEN delivered_date <= promised_date THEN 1 ELSE 0 END) AS on_time_orders,
  SUM(CASE WHEN delivered_date > promised_date THEN 1 ELSE 0 END) AS late_orders,
  ROUND(
    SUM(CASE WHEN delivered_date <= promised_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) AS on_time_pct
FROM orders
WHERE delivered_date IS NOT NULL;


-- -------------------------------------------------
-- 3) Average lateness (days) for late deliveries only
-- -------------------------------------------------
SELECT
  ROUND(AVG(julianday(delivered_date) - julianday(promised_date)), 2) AS avg_late_days,
  ROUND(MAX(julianday(delivered_date) - julianday(promised_date)), 2) AS max_late_days
FROM orders
WHERE delivered_date IS NOT NULL
  AND delivered_date > promised_date;


-- -------------------------------------------------
-- 4) Average cycle time (order -> delivered), delivered only
-- -------------------------------------------------
SELECT
  ROUND(AVG(julianday(delivered_date) - julianday(order_date)), 2) AS avg_cycle_days,
  ROUND(MIN(julianday(delivered_date) - julianday(order_date)), 2) AS min_cycle_days,
  ROUND(MAX(julianday(delivered_date) - julianday(order_date)), 2) AS max_cycle_days
FROM orders
WHERE delivered_date IS NOT NULL;


-- -------------------------------------------------
-- 5) Process time KPI from operations (hours)
-- -------------------------------------------------
SELECT
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours,
  ROUND(MIN(proces_time_hours), 2) AS min_process_hours,
  ROUND(MAX(proces_time_hours), 2) AS max_process_hours
FROM operations;


-- -------------------------------------------------
-- 6) Warehouse performance: volume + avg process time
-- -------------------------------------------------
SELECT
  warehouse,
  COUNT(*) AS orders_handled,
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours,
  ROUND(MAX(proces_time_hours), 2) AS max_process_hours
FROM operations
GROUP BY warehouse
ORDER BY orders_handled DESC;


-- -------------------------------------------------
-- 7) Delay reasons distribution (only where delayed reason exists)
-- -------------------------------------------------
SELECT
  delay_reasons,
  COUNT(*) AS occurrences,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM operations WHERE delay_reasons IS NOT NULL), 2) AS pct_of_delays
FROM operations
WHERE delay_reasons IS NOT NULL
GROUP BY delay_reasons
ORDER BY occurrences DESC;


-- -------------------------------------------------
-- 8) Delay rate by warehouse
-- -------------------------------------------------
SELECT
  warehouse,
  COUNT(*) AS total_ops,
  SUM(CASE WHEN delay_reasons IS NOT NULL THEN 1 ELSE 0 END) AS delayed_ops,
  ROUND(SUM(CASE WHEN delay_reasons IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct,
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours
FROM operations
GROUP BY warehouse
ORDER BY delay_rate_pct DESC;


-- -------------------------------------------------
-- 9) Monthly trend: orders + on-time % (delivered only)
-- -------------------------------------------------
WITH delivered AS (
  SELECT
    substr(order_date, 1, 7) AS order_month,
    delivered_date,
    promised_date
  FROM orders
  WHERE delivered_date IS NOT NULL
)
SELECT
  order_month,
  COUNT(*) AS delivered_orders,
  ROUND(SUM(CASE WHEN delivered_date <= promised_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivered
GROUP BY order_month
ORDER BY order_month;


-- -------------------------------------------------
-- 10) Monthly trend: avg process hours by warehouse
-- -------------------------------------------------
WITH ops_month AS (
  SELECT
    substr(o.order_date, 1, 7) AS order_month,
    op.warehouse,
    op.proces_time_hours
  FROM operations op
  JOIN orders o
    ON o.order_id = op.order_id
)
SELECT
  order_month,
  warehouse,
  COUNT(*) AS orders_handled,
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours
FROM ops_month
GROUP BY order_month, warehouse
ORDER BY order_month, warehouse;
