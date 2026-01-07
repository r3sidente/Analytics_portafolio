-- =========================
-- 03_trends.sql
-- Time trends for operations & delivery performance
-- SQLite compatible
-- =========================

-- -------------------------------------------------
-- 1) Monthly order volume (how demand changes over time)
-- What it's for:
--   Shows seasonality and workload changes month to month.
-- -------------------------------------------------
SELECT
  substr(order_date, 1, 7) AS order_month,
  COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;


-- -------------------------------------------------
-- 2) Monthly delivered vs open (backlog visibility)
-- What it's for:
--   Tracks whether open orders accumulate (operational backlog risk).
-- -------------------------------------------------
SELECT
  substr(order_date, 1, 7) AS order_month,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN delivered_date IS NOT NULL THEN 1 ELSE 0 END) AS delivered_orders,
  SUM(CASE WHEN delivered_date IS NULL THEN 1 ELSE 0 END) AS open_orders,
  ROUND(SUM(CASE WHEN delivered_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delivered_rate_pct
FROM orders
GROUP BY order_month
ORDER BY order_month;


-- -------------------------------------------------
-- 3) Monthly on-time % (service level trend)
-- What it's for:
--   Shows if delivery performance is improving or degrading over time.
-- Notes:
--   Only considers delivered orders.
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
-- 4) Monthly cycle time (order -> delivered), delivered only
-- What it's for:
--   Measures lead time trend; rising lead time usually signals bottlenecks.
-- -------------------------------------------------
WITH delivered AS (
  SELECT
    substr(order_date, 1, 7) AS order_month,
    (julianday(delivered_date) - julianday(order_date)) AS cycle_days
  FROM orders
  WHERE delivered_date IS NOT NULL
)
SELECT
  order_month,
  ROUND(AVG(cycle_days), 2) AS avg_cycle_days,
  ROUND(MAX(cycle_days), 2) AS max_cycle_days
FROM delivered
GROUP BY order_month
ORDER BY order_month;


-- -------------------------------------------------
-- 5) Monthly average process hours (overall operations efficiency trend)
-- What it's for:
--   Indicates warehouse/process efficiency changes over time.
-- Note:
--   Joins operations to orders to use order_date as the time anchor.
-- -------------------------------------------------
WITH ops_month AS (
  SELECT
    substr(o.order_date, 1, 7) AS order_month,
    op.proces_time_hours AS proces_time_hours
  FROM operations op
  JOIN orders o ON o.order_id = op.order_id
)
SELECT
  order_month,
  COUNT(*) AS ops_rows,
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours,
  ROUND(MAX(proces_time_hours), 2) AS max_process_hours
FROM ops_month
GROUP BY order_month
ORDER BY order_month;


-- -------------------------------------------------
-- 6) Monthly warehouse performance (volume + avg process hours)
-- What it's for:
--   Compares warehouses over time. Helps identify which warehouse got worse/better.
-- Important:
--   Uses COUNT(DISTINCT order_id) to avoid double-count if multiple ops per order exist.
-- -------------------------------------------------
WITH ops_month AS (
  SELECT
    substr(o.order_date, 1, 7) AS order_month,
    op.warehouse,
    op.order_id,
    op.proces_time_hours AS proces_time_hours
  FROM operations op
  JOIN orders o ON o.order_id = op.order_id
)
SELECT
  order_month,
  warehouse,
  COUNT(DISTINCT order_id) AS orders_handled,
  ROUND(AVG(proces_time_hours), 2) AS avg_process_hours,
  ROUND(MAX(proces_time_hours), 2) AS max_process_hours
FROM ops_month
GROUP BY order_month, warehouse
ORDER BY order_month, warehouse;


-- -------------------------------------------------
-- 7) Monthly delay reasons (what is driving delays over time)
-- What it's for:
--   Tells you which reason spikes in certain months (e.g., weather, backlog).
-- -------------------------------------------------
WITH delays AS (
  SELECT
    substr(o.order_date, 1, 7) AS order_month,
    op.delay_reasons
  FROM operations op
  JOIN orders o ON o.order_id = op.order_id
  WHERE op.delay_reasons IS NOT NULL
)
SELECT
  order_month,
  delay_reasons,
  COUNT(*) AS occurrences
FROM delays
GROUP BY order_month, delay_reasons
ORDER BY order_month, occurrences DESC;


-- -------------------------------------------------
-- 8) Monthly delay rate by warehouse (service risk per site)
-- What it's for:
--   Shows where delays happen more frequently, and how that changes month to month.
-- -------------------------------------------------
WITH wh AS (
  SELECT
    substr(o.order_date, 1, 7) AS order_month,
    op.warehouse,
    op.order_id,
    op.delay_reasons
  FROM operations op
  JOIN orders o ON o.order_id = op.order_id
)
SELECT
  order_month,
  warehouse,
  COUNT(DISTINCT order_id) AS orders_handled,
  SUM(CASE WHEN delay_reasons IS NOT NULL THEN 1 ELSE 0 END) AS delayed_orders,
  ROUND(SUM(CASE WHEN delay_reasons IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT order_id), 2) AS delay_rate_pct
FROM wh
GROUP BY order_month, warehouse
ORDER BY order_month, delay_rate_pct DESC;
