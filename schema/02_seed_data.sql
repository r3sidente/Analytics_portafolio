PRAGMA foreign_keys = ON;

-- Clean start
DELETE FROM operations;
DELETE FROM orders;

-- 4 warehouses
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 2000
)
INSERT INTO orders (order_id, order_date, promised_date, delivered_date, status)
SELECT
  n AS order_id,
  date('2025-01-01', printf('+%d days', abs(random()) % 365)) AS order_date,
  date(order_date, printf('+%d days', 2 + abs(random()) % 6)) AS promised_date,
  CASE
    -- 10% still open (no delivered_date)
    WHEN (abs(random()) % 100) < 10 THEN NULL
    -- 20% delayed
    WHEN (abs(random()) % 100) < 30 THEN date(promised_date, printf('+%d days', 1 + abs(random()) % 7))
    -- otherwise on time
    ELSE date(promised_date, printf('-%d days', abs(random()) % 2))
  END AS delivered_date,
  CASE
    WHEN delivered_date IS NULL THEN 'open'
    WHEN delivered_date > promised_date THEN 'delayed'
    ELSE 'completed'
  END AS status
FROM seq;

-- operations rows (1 per order)
WITH RECURSIVE seq2(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq2 WHERE n < 2000
)
INSERT INTO operations (operation_id, order_id, warehouse, process_time_hours, delay_reason)
SELECT
  n AS operation_id,
  n AS order_id,
  CASE (abs(random()) % 4)
    WHEN 0 THEN 'WH_A'
    WHEN 1 THEN 'WH_B'
    WHEN 2 THEN 'WH_C'
    ELSE 'WH_D'
  END AS warehouse,
  ROUND(1 + (abs(random()) % 120) / 10.0, 2) AS process_time_hours,
  CASE
    WHEN (abs(random()) % 100) < 65 THEN NULL
    ELSE
      CASE (abs(random()) % 5)
        WHEN 0 THEN 'Inventory shortage'
        WHEN 1 THEN 'Picking delay'
        WHEN 2 THEN 'Carrier capacity'
        WHEN 3 THEN 'System issue'
        ELSE 'Quality rework'
      END
  END AS delay_reason
FROM seq2;
