SELECT
  `__mb_source`.`sum` AS `sum`,
  `__mb_source`.`sum_2` AS `sum_2`,
  `toFloat64`(`__mb_source`.`sum`) + `toFloat64`(`__mb_source`.`sum_2`) AS `Suma`
FROM
  (
    SELECT
      SUM(`olist_raw`.`order_items`.`price`) AS `sum`,
      SUM(`olist_raw`.`order_items`.`freight_value`) AS `sum_2`
    FROM
      `olist_raw`.`order_items`
  ) AS `__mb_source`