CREATE SCHEMA IF NOT EXISTS olist;

-- Customers
DROP TABLE IF EXISTS olist.customers CASCADE;
CREATE TABLE olist.customers (
    customer_id                 TEXT PRIMARY KEY,
    customer_unique_id          TEXT,
    customer_zip_code_prefix    INTEGER,
    customer_city               TEXT,
    customer_state              TEXT
);

-- Sellers
DROP TABLE IF EXISTS olist.sellers CASCADE;
CREATE TABLE olist.sellers (
    seller_id                   TEXT PRIMARY KEY,
    seller_zip_code_prefix      INTEGER,
    seller_city                 TEXT,
    seller_state                TEXT
);

-- Geolocation
DROP TABLE IF EXISTS olist.geolocation CASCADE;
CREATE TABLE olist.geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

-- Products and categories
DROP TABLE IF EXISTS olist.products CASCADE;
CREATE TABLE olist.products (
    product_id                          TEXT PRIMARY KEY,
    product_category_name               TEXT,
    product_name_lenght                 INTEGER,
    product_description_lenght          INTEGER,
    product_photos_qty                  INTEGER,
    product_weight_g                    INTEGER,
    product_length_cm                   INTEGER,
    product_height_cm                   INTEGER,
    product_width_cm                    INTEGER
);

DROP TABLE IF EXISTS olist.product_category_name_translation CASCADE;
CREATE TABLE olist.product_category_name_translation (
    product_category_name               TEXT PRIMARY KEY,
    product_category_name_english       TEXT
);

-- Orders
DROP TABLE IF EXISTS olist.orders CASCADE;
CREATE TABLE olist.orders (
    order_id                            TEXT PRIMARY KEY,
    customer_id                         TEXT REFERENCES olist.customers(customer_id),
    order_status                        TEXT,
    order_purchase_timestamp            TIMESTAMP,
    order_approved_at                   TIMESTAMP,
    order_delivered_carrier_date        TIMESTAMP,
    order_delivered_customer_date       TIMESTAMP,
    order_estimated_delivery_date       TIMESTAMP
);

-- Order items
DROP TABLE IF EXISTS olist.order_items CASCADE;
CREATE TABLE olist.order_items (
    order_id            TEXT REFERENCES olist.orders(order_id),
    order_item_id       INTEGER,
    product_id          TEXT REFERENCES olist.products(product_id),
    seller_id           TEXT REFERENCES olist.sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(12,2),
    freight_value       NUMERIC(12,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Order payments
DROP TABLE IF EXISTS olist.order_payments CASCADE;
CREATE TABLE olist.order_payments (
    order_id                TEXT REFERENCES olist.orders(order_id),
    payment_sequential      INTEGER,
    payment_type            TEXT,
    payment_installments    INTEGER,
    payment_value           NUMERIC(12,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_orders_customer ON olist.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_items_product ON olist.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_items_seller  ON olist.order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON olist.order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_customers_zip ON olist.customers(customer_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_sellers_zip   ON olist.sellers(seller_zip_code_prefix);
CREATE INDEX IF NOT EXISTS idx_geo_zip       ON olist.geolocation(geolocation_zip_code_prefix);
