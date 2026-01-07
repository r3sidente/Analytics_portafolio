-- Data quality checks

-- Orders with missing delivery date
SELECT *
FROM orders
WHERE delivered_date IS NULL;

-- Orders delivered before order date
SELECT *
FROM orders
WHERE delivered_date < order_date;

-- Invalid process times
SELECT *
FROM operations
WHERE process_time_hours <= 0;
