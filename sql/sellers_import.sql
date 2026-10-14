CREATE TABLE IF NOT EXISTS olist_raw.sellers
(
    seller_id String,
    seller_zip_code_prefix String,
    seller_city LowCardinality(String),
    seller_state LowCardinality(String) -- LowCardinality -> because we have limited options for Brazilian states (improves speed)
)
ENGINE = MergeTree
ORDER BY (seller_id);

TRUNCATE TABLE IF EXISTS olist_raw.sellers;

INSERT INTO olist_raw.sellers
SELECT * FROM file('olist/olist_sellers_dataset.csv', 'CSVWithNames');