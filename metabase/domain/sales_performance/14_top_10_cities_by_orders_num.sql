SELECT
  `Customers`.`customer_city` AS `Customers__customer_city`,
  count(distinct `olist_raw`.`orders`.`order_id`) AS `count`
FROM
  `olist_raw`.`orders`
  LEFT JOIN (
    SELECT
      `olist_raw`.`customers`.`customer_id` AS `customer_id`,
      `olist_raw`.`customers`.`customer_unique_id` AS `customer_unique_id`,
      `olist_raw`.`customers`.`customer_zip_code_prefix` AS `customer_zip_code_prefix`,
      `olist_raw`.`customers`.`customer_city` AS `customer_city`,
      `olist_raw`.`customers`.`customer_state` AS `customer_state`
    FROM
      `olist_raw`.`customers`
  ) AS `Customers` ON `olist_raw`.`orders`.`customer_id` = `Customers`.`customer_id`
GROUP BY
  `Customers`.`customer_city`
ORDER BY
  `count` DESC,
  `Customers`.`customer_city` ASC
LIMIT
  10