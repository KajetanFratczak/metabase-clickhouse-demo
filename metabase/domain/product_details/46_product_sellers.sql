-- Sprzedawcy produktu: sztuki, zamówienia i wartość u każdego sprzedawcy, z miastem i stanem (najpierw sumy w CTE, potem złączenie).
-- Zmienne: produkt (Text, wymagana, domyślnie aca2eb7d00ea1a7b8ebd4e68314663af).
WITH podsumowanie AS
(
 	SELECT
		olist_raw.order_items.seller_id AS id_sprzedawcy,
		count() AS liczba_pozycji,
		count(DISTINCT olist_raw.order_items.order_id) AS liczba_zamowien,
		sum(olist_raw.order_items.price) AS wartosc_produktow
	FROM
		olist_raw.order_items
	WHERE olist_raw.order_items.product_id = {{produkt}}
	GROUP BY olist_raw.order_items.seller_id
) 
SELECT 
	id_sprzedawcy,
	liczba_pozycji,
	liczba_zamowien,
	wartosc_produktow,
	olist_raw.sellers.seller_city AS miasto,
	olist_raw.sellers.seller_state AS stan
FROM podsumowanie
LEFT JOIN olist_raw.sellers
	ON podsumowanie.id_sprzedawcy = olist_raw.sellers.seller_id
ORDER BY wartosc_produktow DESC, id_sprzedawcy DESC;