CREATE TABLE orders(
    order_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    shipping_address TEXT NOT NULL,
    -- 'UNCONFIRMED', 'CONFIRMED', 'CANCELLED', 'SHIPPING'
    order_status TEXT NOT NULL,
    confirmed_at TEXT,
    cancelled_at TEXT,
    cancel_reason TEXT,
    shipping_started_at TEXT,
    shipped_by INTEGER,
    scheduled_arrival_date TEXT
);

CREATE TABLE order_lines(
    order_line_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL
);
