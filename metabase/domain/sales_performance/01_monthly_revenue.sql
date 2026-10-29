SELECT
  `toStartOfMonth`(`Orders`.`order_purchase_timestamp`) AS `Orders__order_purchase_timestamp`,
  SUM(`olist_raw`.`order_items`.`price`) AS `sum`
FROM
  `olist_raw`.`order_items`
  LEFT JOIN (
    SELECT
      `olist_raw`.`orders`.`order_id` AS `order_id`,
      `olist_raw`.`orders`.`customer_id` AS `customer_id`,
      `olist_raw`.`orders`.`order_status` AS `order_status`,
      `olist_raw`.`orders`.`order_purchase_timestamp` AS `order_purchase_timestamp`,
      `olist_raw`.`orders`.`order_approved_at` AS `order_approved_at`,
      `olist_raw`.`orders`.`order_delivered_carrier_date` AS `order_delivered_carrier_date`,
      `olist_raw`.`orders`.`order_delivered_customer_date` AS `order_delivered_customer_date`,
      `olist_raw`.`orders`.`order_estimated_delivery_date` AS `order_estimated_delivery_date`
    FROM
      `olist_raw`.`orders`
  ) AS `Orders` ON `olist_raw`.`order_items`.`order_id` = `Orders`.`order_id`
  LEFT JOIN (
    SELECT
      `olist_raw`.`customers`.`customer_id` AS `customer_id`,
      `olist_raw`.`customers`.`customer_unique_id` AS `customer_unique_id`,
      `olist_raw`.`customers`.`customer_zip_code_prefix` AS `customer_zip_code_prefix`,
      `olist_raw`.`customers`.`customer_city` AS `customer_city`,
      `olist_raw`.`customers`.`customer_state` AS `customer_state`
    FROM
      `olist_raw`.`customers`
  ) AS `Customers` ON `Orders`.`customer_id` = `Customers`.`customer_id`
WHERE
  (
    `Orders`.`order_purchase_timestamp` >= `parseDateTimeBestEffort`('2017-01-01 00:00:00.000', 'UTC')
  )
  AND (
    `Orders`.`order_purchase_timestamp` < `parseDateTimeBestEffort`('2018-09-01 00:00:00.000', 'UTC')
  )
GROUP BY
  `toStartOfMonth`(`Orders`.`order_purchase_timestamp`)
ORDER BY
  `toStartOfMonth`(`Orders`.`order_purchase_timestamp`) ASC