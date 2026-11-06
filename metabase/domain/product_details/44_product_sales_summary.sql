-- Podsumowanie sprzedaży produktu: sztuki, zamówienia, sprzedawcy, wartość i transport, ceny min/max/średnia, pierwsze i ostatnie zamówienie, średnia ocena zamówień z produktem. Wizualizacja Detail.
-- Zmienne: produkt (Text, wymagana, domyślnie aca2eb7d00ea1a7b8ebd4e68314663af).
SELECT
	olist_raw.products.product_id AS id_produktu,
	(SELECT count() FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS liczba_pozycji,
	(SELECT count(DISTINCT order_id) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS liczba_zamowien,
	(SELECT count(DISTINCT seller_id) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS liczba_sprzedawcow,
	(SELECT sum(price) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS wartosc_produktow,
	(SELECT sum(freight_value) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS koszt_transportu,
	wartosc_produktow + koszt_transportu AS wartosc_z_transportem,
	(SELECT minOrNull(price) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS cena_minimalna,
	(SELECT maxOrNull(price) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS cena_maksymalna,
	(SELECT avgOrNull(price) FROM olist_raw.order_items WHERE product_id = {{produkt}}) AS cena_srednia,
	(SELECT minOrNull(order_purchase_timestamp) FROM olist_raw.orders WHERE order_id IN (SELECT order_id FROM olist_raw.order_items WHERE product_id = {{produkt}})) AS pierwsze_zamowienie,
	(SELECT maxOrNull(order_purchase_timestamp) FROM olist_raw.orders WHERE order_id IN (SELECT order_id FROM olist_raw.order_items WHERE product_id = {{produkt}})) AS ostatnie_zamowienie,
	(SELECT avgOrNull(review_score) FROM olist_raw.reviews WHERE order_id IN (SELECT order_id FROM olist_raw.order_items WHERE product_id = {{produkt}})) AS srednia_ocena_zamowien_z_produktem
FROM 
	olist_raw.products
WHERE olist_raw.products.product_id = {{produkt}};