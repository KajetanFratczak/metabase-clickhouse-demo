CREATE TABLE IF NOT EXISTS olist_raw.geolocation
(
    geolocation_zip_code_prefix String,
    geolocation_lat Float64,
    geolocation_lng Float64,
    geolocation_city LowCardinality(String),
    geolocation_state LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY (geolocation_zip_code_prefix);

TRUNCATE TABLE IF EXISTS olist_raw.geolocation;

INSERT INTO olist_raw.geolocation
SELECT * FROM file('olist/olist_geolocation_dataset.csv', 'CSVWithNames');