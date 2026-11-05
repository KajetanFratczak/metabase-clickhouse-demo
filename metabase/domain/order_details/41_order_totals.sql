-- Podsumowanie zamówienia: liczba pozycji, wartość produktów, transport, suma płatności i różnica (płatności minus wartość z transportem). Wizualizacja Detail.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
SELECT
	olist_raw.orders.order_id AS id_zamowienia,
	(SELECT count() FROM olist_raw.order_items WHERE order_id = {{zamowienie}}) AS pozycje,
	(SELECT sum(price) FROM olist_raw.order_items WHERE order_id = {{zamowienie}}) AS wartosc_produktow,
	(SELECT sum(payment_value) FROM olist_raw.payments WHERE order_id = {{zamowienie}}) AS suma_platnosci,
	(SELECT sum(freight_value) FROM olist_raw.order_items WHERE order_id = {{zamowienie}}) AS koszt_transportu,
	wartosc_produktow + koszt_transportu AS wartosc_z_transportem,
	suma_platnosci - wartosc_z_transportem AS roznica
FROM 
	olist_raw.orders
WHERE olist_raw.orders.order_id = {{zamowienie}};
