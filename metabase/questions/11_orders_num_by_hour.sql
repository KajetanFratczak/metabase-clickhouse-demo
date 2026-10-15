SELECT
  `toHour`(`olist_raw`.`orders`.`order_purchase_timestamp`) AS `order_purchase_timestamp`,
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`
GROUP BY
  `toHour`(`olist_raw`.`orders`.`order_purchase_timestamp`)
ORDER BY
  `toHour`(`olist_raw`.`orders`.`order_purchase_timestamp`) ASC