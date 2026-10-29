SELECT
  COUNT(*) AS `count`
FROM
  `olist_raw`.`products`
  LEFT JOIN (
    SELECT
      `olist_raw`.`category_name_translation`.`product_category_name` AS `product_category_name`,
      `olist_raw`.`category_name_translation`.`product_category_name_english` AS `product_category_name_english`
    FROM
      `olist_raw`.`category_name_translation`
  ) AS `Category Name Translation - Product Category Name` ON `olist_raw`.`products`.`product_category_name` = `Category Name Translation - Product Category Name`.`product_category_name`