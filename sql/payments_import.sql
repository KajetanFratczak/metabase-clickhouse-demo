CREATE TABLE IF NOT EXISTS olist_raw.payments
(
    order_id String,
    payment_sequential UInt8,
    payment_type LowCardinality(String),
    payment_installments UInt8,
    payment_value Decimal(10,2)
)
ENGINE = MergeTree
ORDER BY (order_id, payment_sequential);

TRUNCATE TABLE IF EXISTS olist_raw.payments;

INSERT INTO olist_raw.payments
SELECT * FROM file('olist/olist_order_payments_dataset.csv', 'CSVWithNames');