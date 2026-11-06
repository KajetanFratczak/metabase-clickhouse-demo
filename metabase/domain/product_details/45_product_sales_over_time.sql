-- Sprzedaż produktu wg miesiąca zakupu: sztuki, zamówienia i wartość. Wykres słupkowy z dwiema osiami.
-- Zmienne: produkt (Text, wymagana, domyślnie aca2eb7d00ea1a7b8ebd4e68314663af).
SELECT
	toStartOfMonth(olist_raw.orders.order_purchase_timestamp) AS miesiac_zakupu,
	count() AS liczba_pozycji,
	count(DISTINCT olist_raw.order_items.order_id) AS liczba_zamowien,
	sum(olist_raw.order_items.price) AS wartosc_produktow
FROM
	olist_raw.order_items
LEFT JOIN olist_raw.orders 
	ON olist_raw.order_items.order_id = olist_raw.orders.order_id
WHERE olist_raw.order_items.product_id = {{produkt}}
GROUP BY toStartOfMonth(olist_raw.orders.order_purchase_timestamp)
ORDER BY miesiac_zakupu ASC;