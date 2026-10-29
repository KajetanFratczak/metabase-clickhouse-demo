SELECT
  SUM(`Order Items - Order`.`price`) AS `sum`
FROM
  `olist_raw`.`orders`
  LEFT JOIN (
    SELECT
      `olist_raw`.`order_items`.`order_id` AS `order_id`,
      `olist_raw`.`order_items`.`order_item_id` AS `order_item_id`,
      `olist_raw`.`order_items`.`product_id` AS `product_id`,
      `olist_raw`.`order_items`.`seller_id` AS `seller_id`,
      `olist_raw`.`order_items`.`shipping_limit_date` AS `shipping_limit_date`,
      `olist_raw`.`order_items`.`price` AS `price`,
      `olist_raw`.`order_items`.`freight_value` AS `freight_value`
    FROM
      `olist_raw`.`order_items`
  ) AS `Order Items - Order` ON `olist_raw`.`orders`.`order_id` = `Order Items - Order`.`order_id`
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