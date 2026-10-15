SELECT
  (
    (
      `toDayOfWeek`(`olist_raw`.`orders`.`order_purchase_timestamp`) % 7
    ) + 1
  ) AS `order_purchase_timestamp`,
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`
GROUP BY
  (
    (
      `toDayOfWeek`(`olist_raw`.`orders`.`order_purchase_timestamp`) % 7
    ) + 1
  )
ORDER BY
  (
    (
      `toDayOfWeek`(`olist_raw`.`orders`.`order_purchase_timestamp`) % 7
    ) + 1
  ) ASC