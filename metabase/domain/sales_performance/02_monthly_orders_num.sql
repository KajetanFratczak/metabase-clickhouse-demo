SELECT
  `toStartOfMonth`(`olist_raw`.`orders`.`order_purchase_timestamp`) AS `order_purchase_timestamp`,
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`
  LEFT JOIN (
    SELECT
      `olist_raw`.`customers`.`customer_id` AS `customer_id`,
      `olist_raw`.`customers`.`customer_unique_id` AS `customer_unique_id`,
      `olist_raw`.`customers`.`customer_zip_code_prefix` AS `customer_zip_code_prefix`,
      `olist_raw`.`customers`.`customer_city` AS `customer_city`,
      `olist_raw`.`customers`.`customer_state` AS `customer_state`
    FROM
      `olist_raw`.`customers`
  ) AS `Customers` ON `olist_raw`.`orders`.`customer_id` = `Customers`.`customer_id`
WHERE
  (
    `olist_raw`.`orders`.`order_purchase_timestamp` >= `parseDateTimeBestEffort`('2017-01-01 00:00:00.000', 'UTC')
  )
  AND (
    `olist_raw`.`orders`.`order_purchase_timestamp` < `parseDateTimeBestEffort`('2018-09-01 00:00:00.000', 'UTC')
  )
GROUP BY
  `toStartOfMonth`(`olist_raw`.`orders`.`order_purchase_timestamp`)
ORDER BY
  `toStartOfMonth`(`olist_raw`.`orders`.`order_purchase_timestamp`) ASC