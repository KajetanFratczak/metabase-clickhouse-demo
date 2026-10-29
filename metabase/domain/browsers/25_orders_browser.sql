SELECT
  `olist_raw`.`orders`.`order_id` AS `order_id`,
  `olist_raw`.`orders`.`order_purchase_timestamp` AS `order_purchase_timestamp`,
  `olist_raw`.`orders`.`order_status` AS `order_status`,
  `olist_raw`.`orders`.`customer_id` AS `customer_id`,
  `olist_raw`.`orders`.`order_estimated_delivery_date` AS `order_estimated_delivery_date`,
  `olist_raw`.`orders`.`order_delivered_customer_date` AS `order_delivered_customer_date`,
  CONCAT(
    `olist_raw`.`orders`.`order_id`,
    ' ',
    `olist_raw`.`orders`.`customer_id`,
    ' ',
    `Customers`.`customer_city`
  ) AS `Szukaj`,
  `Customers`.`customer_city` AS `Customers__customer_city`,
  `Customers`.`customer_state` AS `Customers__customer_state`
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
ORDER BY
  `olist_raw`.`orders`.`order_purchase_timestamp` DESC,
  `olist_raw`.`orders`.`order_id` ASC