SELECT
  `olist_raw`.`customers`.`customer_id` AS `customer_id`,
  `olist_raw`.`customers`.`customer_unique_id` AS `customer_unique_id`,
  `olist_raw`.`customers`.`customer_zip_code_prefix` AS `customer_zip_code_prefix`,
  `olist_raw`.`customers`.`customer_city` AS `customer_city`,
  `olist_raw`.`customers`.`customer_state` AS `customer_state`,
  CONCAT(
    `olist_raw`.`customers`.`customer_id`,
    ' ',
    `olist_raw`.`customers`.`customer_unique_id`,
    ' ',
    `olist_raw`.`customers`.`customer_city`,
    ' ',
    `olist_raw`.`customers`.`customer_zip_code_prefix`
  ) AS `Szukaj`
FROM
  `olist_raw`.`customers`
ORDER BY
  `olist_raw`.`customers`.`customer_unique_id` ASC