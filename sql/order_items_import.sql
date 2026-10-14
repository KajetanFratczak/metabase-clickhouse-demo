CREATE TABLE IF NOT EXISTS olist_raw.order_items
(
    order_id String,
    order_item_id UInt8,
    product_id String,
    seller_id String,
    shipping_limit_date DateTime,
    price Decimal(10,2),
    freight_value Decimal(10,2)
)
ENGINE = MergeTree
ORDER BY (order_id, order_item_id);

TRUNCATE TABLE IF EXISTS olist_raw.order_items;

INSERT INTO olist_raw.order_items
SELECT * FROM file('olist/olist_order_items_dataset.csv', 'CSVWithNames');