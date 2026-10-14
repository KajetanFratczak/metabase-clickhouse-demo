CREATE TABLE IF NOT EXISTS olist_raw.orders
(
    order_id String,
    customer_id String,
    order_status LowCardinality(String),
    order_purchase_timestamp DateTime,
    order_approved_at Nullable(DateTime),
    order_delivered_carrier_date Nullable(DateTime),
    order_delivered_customer_date Nullable(DateTime),
    order_estimated_delivery_date DateTime
)
ENGINE = MergeTree
ORDER BY (order_purchase_timestamp, order_id);

TRUNCATE TABLE IF EXISTS olist_raw.orders;

INSERT INTO olist_raw.orders
SELECT * FROM file('olist/olist_orders_dataset.csv', 'CSVWithNames');