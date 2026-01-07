-- Base view: one row per order with derived fields used everywhere

-- Replace DATE_DIFF / DATEDIFF depending on your SQL engine
CREATE VIEW v_order_metrics AS
SELECT
  o.order_id,
  o.order_date,
  o.promised_date,
  o.delivered_date,
  CASE WHEN o.delivered_date IS NULL THEN 1 ELSE 0 END AS is_open,
  CASE WHEN o.delivered_date > o.promised_date THEN 1 ELSE 0 END AS is_delayed,
  /* lead_time_days */
  /* delay_days (only when delayed) */
  op.warehouse,
  op.process_time_hours,
  op.delay_reason
FROM orders o
JOIN operations op
  ON o.order_id = op.order_id;
