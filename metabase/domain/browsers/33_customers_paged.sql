-- Przeglądarka klientów: jedna strona wyników (50 wierszy). Filtry, sortowanie i stronicowanie wykonuje ClickHouse.
-- Zmienne: szukaj (Text), stan (Field Filter: Customers -> Customer State), miasto (Field Filter: Customers -> Customer City), osoba (Text), sortuj (Text, domyślnie miasto, wymagana), strona (Number, domyślnie 1, wymagana).
-- Sortuj: miasto, stan, osoba. Opcja osoba korzysta z kolejności customer_unique_id, customer_id; inne nierozpoznane wartości mają tę samą kolejność.

SELECT
  olist_raw.customers.customer_id AS klient_id,
  olist_raw.customers.customer_unique_id AS osoba,
  olist_raw.customers.customer_zip_code_prefix AS prefiks_kodu_pocztowego,
  olist_raw.customers.customer_city AS miasto,
  olist_raw.customers.customer_state AS stan
FROM olist_raw.customers
WHERE 1 = 1
	[[AND positionCaseInsensitiveUTF8(concat(olist_raw.customers.customer_id, ' ', olist_raw.customers.customer_unique_id, ' ', olist_raw.customers.customer_city, ' ', olist_raw.customers.customer_zip_code_prefix), {{szukaj}}) > 0]]
	[[AND {{stan}}]]
	[[AND {{miasto}}]]
	[[AND olist_raw.customers.customer_unique_id = {{osoba}}]]
ORDER BY 
	multiIf(
		{{sortuj}} = 'miasto', toString(olist_raw.customers.customer_city),
		{{sortuj}} = 'stan', toString(olist_raw.customers.customer_state),
		''
	) ASC,
	olist_raw.customers.customer_unique_id ASC,
	olist_raw.customers.customer_id ASC
LIMIT 50 OFFSET (toUInt32(greatest({{strona}}, 1)) - 1) * 50;