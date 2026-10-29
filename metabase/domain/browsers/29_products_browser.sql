SELECT
  `olist_raw`.`products`.`product_id` AS `product_id`,
  `olist_raw`.`products`.`product_category_name` AS `product_category_name`,
  `olist_raw`.`products`.`product_photos_qty` AS `product_photos_qty`,
  `olist_raw`.`products`.`product_weight_g` AS `product_weight_g`,
  `olist_raw`.`products`.`product_length_cm` AS `product_length_cm`,
  `olist_raw`.`products`.`product_height_cm` AS `product_height_cm`,
  `olist_raw`.`products`.`product_width_cm` AS `product_width_cm`,
  CONCAT(
    `olist_raw`.`products`.`product_id`,
    ' ',
    `olist_raw`.`products`.`product_category_name`,
    ' ',
    CASE
      WHEN (
        (
          `olist_raw`.`products`.`product_category_name` IS NULL
        )
        OR (
          `empty`(`olist_raw`.`products`.`product_category_name`) = 1
        )
      )
      OR (
        `olist_raw`.`products`.`product_category_name` = ''
      ) THEN '(brak kategorii)'
      WHEN (
        (
          `Category Name Translation - Product Category Name`.`product_category_name_english` IS NULL
        )
        OR (
          `empty`(
            `Category Name Translation - Product Category Name`.`product_category_name_english`
          ) = 1
        )
      )
      OR (
        `Category Name Translation - Product Category Name`.`product_category_name_english` = ''
      ) THEN `olist_raw`.`products`.`product_category_name`
      ELSE `Category Name Translation - Product Category Name`.`product_category_name_english`
    END
  ) AS `Szukaj`,
  CASE
    WHEN (
      (
        `olist_raw`.`products`.`product_category_name` IS NULL
      )
      OR (
        `empty`(`olist_raw`.`products`.`product_category_name`) = 1
      )
    )
    OR (
      `olist_raw`.`products`.`product_category_name` = ''
    ) THEN '(brak kategorii)'
    WHEN (
      (
        `Category Name Translation - Product Category Name`.`product_category_name_english` IS NULL
      )
      OR (
        `empty`(
          `Category Name Translation - Product Category Name`.`product_category_name_english`
        ) = 1
      )
    )
    OR (
      `Category Name Translation - Product Category Name`.`product_category_name_english` = ''
    ) THEN `olist_raw`.`products`.`product_category_name`
    ELSE `Category Name Translation - Product Category Name`.`product_category_name_english`
  END AS `Kategoria`,
  `Category Name Translation - Product Category Name`.`product_category_name` AS `Category Name Translation - Product Category Name___55e86035`,
  `Category Name Translation - Product Category Name`.`product_category_name_english` AS `Category Name Translation - Product Category Name___14b42bd5`
FROM
  `olist_raw`.`products`
  LEFT JOIN (
    SELECT
      `olist_raw`.`category_name_translation`.`product_category_name` AS `product_category_name`,
      `olist_raw`.`category_name_translation`.`product_category_name_english` AS `product_category_name_english`
    FROM
      `olist_raw`.`category_name_translation`
  ) AS `Category Name Translation - Product Category Name` ON `olist_raw`.`products`.`product_category_name` = `Category Name Translation - Product Category Name`.`product_category_name`
ORDER BY
  `olist_raw`.`products`.`product_id` ASC