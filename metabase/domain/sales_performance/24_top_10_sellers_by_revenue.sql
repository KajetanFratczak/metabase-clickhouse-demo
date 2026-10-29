SELECT
  `Sellers`.`seller_id` AS `Sellers__seller_id`,
  `Sellers`.`seller_city` AS `Sellers__seller_city`,
  `Sellers`.`seller_state` AS `Sellers__seller_state`,
  SUM(`olist_raw`.`order_items`.`price`) AS `sum`,
  count(distinct `olist_raw`.`order_items`.`order_id`) AS `count`
FROM
  `olist_raw`.`order_items`
  LEFT JOIN (
    SELECT
      `olist_raw`.`sellers`.`seller_id` AS `seller_id`,
      `olist_raw`.`sellers`.`seller_zip_code_prefix` AS `seller_zip_code_prefix`,
      `olist_raw`.`sellers`.`seller_city` AS `seller_city`,
      `olist_raw`.`sellers`.`seller_state` AS `seller_state`
    FROM
      `olist_raw`.`sellers`
  ) AS `Sellers` ON `olist_raw`.`order_items`.`seller_id` = `Sellers`.`seller_id`
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
  `Sellers`.`seller_id`,
  `Sellers`.`seller_city`,
  `Sellers`.`seller_state`
ORDER BY
  `sum` DESC,
  `Sellers`.`seller_id` ASC,
  `Sellers`.`seller_city` ASC,
  `Sellers`.`seller_state` ASC
LIMIT
  10