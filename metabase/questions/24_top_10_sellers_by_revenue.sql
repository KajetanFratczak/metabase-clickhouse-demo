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