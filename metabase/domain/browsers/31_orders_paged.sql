-- Przeglądarka zamówień: jedna strona wyników (50 wierszy). Filtry, sortowanie i stronicowanie wykonuje ClickHouse.
-- Zmienne: szukaj (Text), status (Field Filter: Orders -> Order Status), data_zakupu (Field Filter: Orders -> Order Purchase Timestamp), stan (Field Filter: Customers -> Customer State), osoba (Text), sortuj (Text, domyślnie najnowsze, wymagana), strona (Number, domyślnie 1, wymagana).

SELECT
  olist_raw.orders.order_id AS order_id,
  olist_raw.orders.order_purchase_timestamp AS data_zakupu,
  olist_raw.orders.order_status AS status,
  olist_raw.customers.customer_unique_id AS osoba,
  olist_raw.customers.customer_city AS miasto,
  olist_raw.customers.customer_state AS stan,
  olist_raw.orders.order_estimated_delivery_date AS planowana_dostawa,
  olist_raw.orders.order_delivered_customer_date AS dostarczono,
  dateDiff('day', olist_raw.orders.order_estimated_delivery_date, olist_raw.orders.order_delivered_customer_date) AS opoznienie_dni
FROM olist_raw.orders
LEFT JOIN olist_raw.customers
	ON olist_raw.orders.customer_id = olist_raw.customers.customer_id
WHERE 1 = 1
	[[AND positionCaseInsensitiveUTF8(concat(olist_raw.orders.order_id, ' ', olist_raw.orders.customer_id, ' ', olist_raw.customers.customer_unique_id, ' ', olist_raw.cutomers.customer_city), {{szukaj}}) > 0]]
	[[AND {{status}}]]
	[[AND {{data_zakupu}}]]
	[[AND {{stan}}]]
	[[AND olist_raw.customers.customer_unique_id = {{osoba}}]]
ORDER BY 
	multiIf(
		{{sortuj}} = 'najstarsze', toInt64(toUnixTimestamp(olist_raw.orders.order_purchase_timestamp)),
		{{sortuj}} = 'największe opóźnienie', -dateDiff('day', olist_raw.orders.order_estimated_delivery_date, olist_raw.orders.order_delivered_customer_date),
		0
	) ASC,
	multiIf(
		{{sortuj}} = 'status', toString(olist_raw.orders.order_status),
		{{sortuj}} = 'miasto', toString(olist_raw.customers.customer_city),
		''
	) ASC,
	olist_raw.orders.order_purchase_timestamp DESC,
	olist_raw.orders.order_id ASC
LIMIT 50 OFFSET (toUInt32(greatest({{strona}}, 1)) - 1) * 50;