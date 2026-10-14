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