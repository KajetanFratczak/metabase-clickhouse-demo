SELECT
  `__mb_source`.`Customers__customer_city` AS `Customers__customer_city`,
  `__mb_source`.`Średnia wartość zamówienia` AS `Średnia wartość zamówienia`,
  `__mb_source`.`count` AS `count`
FROM
  (
    SELECT
      `Customers`.`customer_city` AS `Customers__customer_city`,
      `toFloat64`(SUM(`olist_raw`.`order_items`.`price`)) / NULLIF(
        `toFloat64`(
          count(distinct `olist_raw`.`order_items`.`order_id`)
        ),
        0.0
      ) AS `Średnia wartość zamówienia`,
      count(distinct `Orders`.`order_id`) AS `count`
    FROM
      `olist_raw`.`order_items`
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
      `Customers`.`customer_city`
    ORDER BY
      `Customers`.`customer_city` ASC
  ) AS `__mb_source`
WHERE
  `__mb_source`.`count` >= 100
ORDER BY
  `__mb_source`.`Średnia wartość zamówienia` DESC
LIMIT
  10