SELECT
  `olist_raw`.`orders`.`order_status` AS `order_status`,
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`
GROUP BY
  `olist_raw`.`orders`.`order_status`
ORDER BY
  `olist_raw`.`orders`.`order_status` ASC