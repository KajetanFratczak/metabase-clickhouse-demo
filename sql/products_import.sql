CREATE TABLE IF NOT EXISTS olist_raw.products
(
    product_id String,
    product_category_name LowCardinality(String),
    product_name_lenght Nullable(UInt16), -- that's a typo, but it's accurate to the dataset
    product_description_lenght Nullable(UInt16), -- that's a typo, but it's accurate to the dataset
    product_photos_qty Nullable(UInt8),
    product_weight_g Nullable(UInt32),
    product_length_cm Nullable(UInt16),
    product_height_cm Nullable(UInt16),
    product_width_cm Nullable(UInt16)
)
ENGINE = MergeTree
ORDER BY (product_id);

TRUNCATE TABLE IF EXISTS olist_raw.products;

INSERT INTO olist_raw.products
SELECT * FROM file('olist/olist_products_dataset.csv', 'CSVWithNames');