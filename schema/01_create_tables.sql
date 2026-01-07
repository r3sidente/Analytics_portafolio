-- Schema creation for operational analytics project

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    promised_date DATE,
    delivered_date DATE,
    status VARCHAR(20)
);

CREATE TABLE operations (
    ops_id INT PRIMARY KEY,
    order_id INT,
    warehouse VARCHAR(50),
    proces_time_hours DECIMAL(10,2),
    delay_reason VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
