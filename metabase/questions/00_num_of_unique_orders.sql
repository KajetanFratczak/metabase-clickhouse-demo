SELECT
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`