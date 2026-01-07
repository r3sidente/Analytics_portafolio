-- ====================================
-- LOAD: operations
-- columns: ops_id, order_id, warehouse, proces_time_hours, delay_reasons
-- ====================================

DELETE FROM operations;

WITH warehouses AS (
  SELECT 'WH-Perth' AS warehouse
  UNION ALL SELECT 'WH-Sydney'
  UNION ALL SELECT 'WH-Melbourne'
  UNION ALL SELECT 'WH-Brisbane'
),
orders_enriched AS (
  SELECT
    o.order_id,
    o.order_date,
    o.promised_date,
    o.delivered_date,
    COALESCE(o.delivered_date, o.promised_date) AS end_date,
    CASE
      WHEN o.delivered_date IS NULL THEN 0
      WHEN o.delivered_date > o.promised_date THEN 1
      ELSE 0
    END AS is_delayed
  FROM orders o
),
ops_rows AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY oe.order_id) AS ops_id,
    oe.order_id,

    -- Random warehouse from list
    (SELECT w.warehouse
     FROM warehouses w
     ORDER BY abs(random())
     LIMIT 1) AS warehouse,

    -- Process time (hours): cycle time in hours + noise, min 1.00
    ROUND(
      MAX(
        1.0,
        ((julianday(oe.end_date) - julianday(oe.order_date)) * 24.0)
        + (abs(random()) % 12)
      ),
      2
    ) AS proces_time_hours,

    -- Delay reason only if delayed
    CASE
      WHEN oe.is_delayed = 0 THEN NULL
      ELSE (
        SELECT reason FROM (
          SELECT 'Carrier delay' AS reason
          UNION ALL SELECT 'Warehouse backlog'
          UNION ALL SELECT 'Stockout'
          UNION ALL SELECT 'Address issue'
          UNION ALL SELECT 'Weather'
        )
        ORDER BY abs(random())
        LIMIT 1
      )
    END AS delay_reasons

  FROM orders_enriched oe
)
INSERT INTO operations (ops_id, order_id, warehouse, proces_time_hours, delay_reasons)
SELECT
  ops_id,
  order_id,
  warehouse,
  proces_time_hours,
  delay_reasons
FROM ops_rows;







-- ====================================
-- LOAD: orders
-- ====================================

-- (opcional) limpia para re-cargar
DELETE FROM orders;

WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 2000
),
base AS (
  SELECT
    n AS order_id,
    date('2025-01-01', '+' || (abs(random()) % 365) || ' days') AS order_date
  FROM seq
),
with_promised AS (
  SELECT
    order_id,
    order_date,
    date(order_date, '+' || (2 + abs(random()) % 6) || ' days') AS promised_date
  FROM base
),
final AS (
  SELECT
    order_id,
    order_date,
    promised_date,
    CASE
      -- 10% still open (no delivered_date)
      WHEN (abs(random()) % 100) < 10 THEN NULL
      -- 20% delayed (delivered after promised)
      WHEN (abs(random()) % 100) < 30 THEN date(promised_date, '+' || (1 + abs(random()) % 7) || ' days')
      -- otherwise on time / early
      ELSE date(promised_date, '-' || (abs(random()) % 2) || ' days')
    END AS delivered_date
  FROM with_promised
)
INSERT INTO orders (order_id, order_date, promised_date, delivered_date, status)
SELECT
  order_id,
  order_date,
  promised_date,
  delivered_date,
  CASE
    WHEN delivered_date IS NULL THEN 'OPEN'
    WHEN delivered_date > promised_date THEN 'DELAYED'
    ELSE 'DELIVERED'
  END AS status
FROM final;
