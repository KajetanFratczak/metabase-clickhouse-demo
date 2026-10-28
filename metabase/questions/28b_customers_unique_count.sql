SELECT
  count(
    distinct `olist_raw`.`customers`.`customer_unique_id`
  ) AS `count`
FROM
  `olist_raw`.`customers`