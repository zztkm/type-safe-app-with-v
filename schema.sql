CREATE TABLE IF NOT EXISTS orders(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    shipping_address TEXT NOT NULL,
    -- 'UNCONFIRMED', 'CONFIRMED', 'CANCELLED', 'SHIPPING'
    order_status TEXT NOT NULL,
    confirmed_at TEXT,
    cancelled_at TEXT,
    cancel_reason TEXT,
    shipping_started_at TEXT,
    shipped_by INT,
    scheduled_arrival_date DATE
);
