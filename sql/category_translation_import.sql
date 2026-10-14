CREATE TABLE IF NOT EXISTS olist_raw.category_name_translation
(
    product_category_name String,
    product_category_name_english String
)
ENGINE = MergeTree
ORDER BY (product_category_name);

TRUNCATE TABLE IF EXISTS olist_raw.category_name_translation;

INSERT INTO olist_raw.category_name_translation
SELECT * FROM file('olist/product_category_name_translation.csv', 'CSVWithNames');