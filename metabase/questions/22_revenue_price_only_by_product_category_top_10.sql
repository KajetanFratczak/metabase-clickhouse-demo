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
GROUP BY
  `Category Name Translation - Product Category Name`.`product_category_name_english`
ORDER BY
  `sum` DESC,
  `Category Name Translation - Product Category Name`.`product_category_name_english` ASC
LIMIT
  10