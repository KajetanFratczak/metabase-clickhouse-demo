CREATE TABLE IF NOT EXISTS olist_raw.customers
(
    customer_id String,
    customer_unique_id String,
    customer_zip_code_prefix String,
    customer_city LowCardinality(String),
    customer_state LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY (customer_unique_id);

TRUNCATE TABLE IF EXISTS olist_raw.customers;

INSERT INTO olist_raw.customers
SELECT * FROM file('olist/olist_customers_dataset.csv', 'CSVWithNames');