-- Zamówienia zawierające produkt: sztuki, wartość i transport w zamówieniu, data i status. Kliknięcie ID zamówienia otwiera jego szczegóły.
-- Zmienne: produkt (Text, wymagana, domyślnie aca2eb7d00ea1a7b8ebd4e68314663af).
WITH podsumowanie AS
(
 	SELECT
		olist_raw.order_items.order_id AS id_zamowienia,
		count() AS liczba_pozycji,
		sum(olist_raw.order_items.price) AS wartosc_produktow,
		sum(olist_raw.order_items.freight_value) AS wartosc_transportu
	FROM
		olist_raw.order_items
	WHERE olist_raw.order_items.product_id = {{produkt}}
	GROUP BY olist_raw.order_items.order_id
) 
SELECT 
	id_zamowienia,
	liczba_pozycji,
	wartosc_produktow,
	wartosc_transportu,
	olist_raw.orders.order_purchase_timestamp AS data_zakupu,
	olist_raw.orders.order_status AS status_zamowienia
FROM podsumowanie
LEFT JOIN olist_raw.orders
	ON podsumowanie.id_zamowienia = olist_raw.orders.order_id
ORDER BY data_zakupu DESC, id_zamowienia DESC;