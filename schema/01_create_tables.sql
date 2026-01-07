-- Schema creation for operational analytics project

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    promised_date DATE,
    delivered_date DATE,
    status VARCHAR(20)
);

CREATE TABLE operations (
    operation_id INT PRIMARY KEY,
    order_id INT,
    warehouse VARCHAR(50),
    process_time_hours DECIMAL(10,2),
    delay_reason VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
