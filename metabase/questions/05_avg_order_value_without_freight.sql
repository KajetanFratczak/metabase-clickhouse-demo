SELECT
  `toFloat64`(SUM(`olist_raw`.`order_items`.`price`)) / NULLIF(
    `toFloat64`(
      count(distinct `olist_raw`.`order_items`.`order_id`)
    ),
    0.0
  ) AS `Średnia wartość zamówienia`
FROM
  `olist_raw`.`order_items`