SELECT
  `Category Name Translation - Product Category Name`.`product_category_name_english` AS `Category Name Translation - Product Category Name___14b42bd5`,
  SUM(`olist_raw`.`order_items`.`price`) AS `sum`
FROM
  `olist_raw`.`order_items`
  LEFT JOIN (
    SELECT
      `olist_raw`.`products`.`product_id` AS `product_id`,
      `olist_raw`.`products`.`product_category_name` AS `product_category_name`,
      `olist_raw`.`products`.`product_name_lenght` AS `product_name_lenght`,
      `olist_raw`.`products`.`product_description_lenght` AS `product_description_lenght`,
      `olist_raw`.`products`.`product_photos_qty` AS `product_photos_qty`,
      `olist_raw`.`products`.`product_weight_g` AS `product_weight_g`,
      `olist_raw`.`products`.`product_length_cm` AS `product_length_cm`,
      `olist_raw`.`products`.`product_height_cm` AS `product_height_cm`,
      `olist_raw`.`products`.`product_width_cm` AS `product_width_cm`
    FROM
      `olist_raw`.`products`
  ) AS `Products` ON `olist_raw`.`order_items`.`product_id` = `Products`.`product_id`
  LEFT JOIN (
    SELECT
      `olist_raw`.`category_name_translation`.`product_category_name` AS `product_category_name`,
      `olist_raw`.`category_name_translation`.`product_category_name_english` AS `product_category_name_english`
    FROM
      `olist_raw`.`category_name_translation`
  ) AS `Category Name Translation - Product Category Name` ON `Products`.`product_category_name` = `Category Name Translation - Product Category Name`.`product_category_name`
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
  `Category Name Translation - Product Category Name`.`product_category_name_english`
ORDER BY
  `sum` DESC,
  `Category Name Translation - Product Category Name`.`product_category_name_english` ASC
LIMIT
  10