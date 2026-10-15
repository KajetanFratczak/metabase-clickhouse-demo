SELECT
  `olist_raw`.`payments`.`payment_type` AS `payment_type`,
  SUM(`olist_raw`.`payments`.`payment_value`) AS `sum`
FROM
  `olist_raw`.`payments`
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
  ) AS `Orders` ON `olist_raw`.`payments`.`order_id` = `Orders`.`order_id`
WHERE
  (
    `olist_raw`.`payments`.`payment_type` <> 'not_defined'
  )
  OR (`olist_raw`.`payments`.`payment_type` IS NULL)
GROUP BY
  `olist_raw`.`payments`.`payment_type`
ORDER BY
  `olist_raw`.`payments`.`payment_type` ASC