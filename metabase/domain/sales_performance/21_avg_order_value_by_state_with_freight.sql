SELECT
  `Customers`.`customer_state` AS `Customers__customer_state`,
  `toFloat64`(
    `toFloat64`(SUM(`olist_raw`.`order_items`.`freight_value`)) + `toFloat64`(SUM(`olist_raw`.`order_items`.`price`))
  ) / NULLIF(
    `toFloat64`(
      count(distinct `olist_raw`.`order_items`.`order_id`)
    ),
    0.0
  ) AS `Średnia wartość zamówienia`
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
GROUP BY
  `Customers`.`customer_state`
ORDER BY
  `Customers`.`customer_state` ASC