CREATE TABLE IF NOT EXISTS olist_raw.reviews
(
    review_id String,
    order_id String,
    review_score UInt8,
    review_comment_title String,
    review_comment_message String,
    review_creation_date DateTime,
    review_answer_timestamp DateTime
)
ENGINE = MergeTree
ORDER BY (order_id, review_id);

TRUNCATE TABLE IF EXISTS olist_raw.reviews;

INSERT INTO olist_raw.reviews
SELECT * FROM file('olist/olist_order_reviews_dataset.csv', 'CSVWithNames');