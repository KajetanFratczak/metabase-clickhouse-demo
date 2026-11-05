-- Produkty z zamówienia: jedna sztuka to jeden wiersz, z kategorią, sprzedawcą, ceną i transportem. Kliknięcie ID produktu otwiera przeglądarkę produktów.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
WITH coalesce(
	nullIf(olist_raw.category_name_translation.product_category_name_english, ''),
	nullIf(toString(olist_raw.products.product_category_name), ''),
	'(brak kategorii)'
) AS nazwa_kategorii
SELECT
	olist_raw.order_items.order_item_id AS pozycja,
	olist_raw.order_items.product_id AS id_produktu,
	olist_raw.order_items.seller_id AS id_sprzedawcy,
	olist_raw.order_items.price AS cena,
	olist_raw.order_items.freight_value AS koszt_transportu,
	cena + koszt_transportu AS wartosc_z_transportem,
	nazwa_kategorii AS kategoria
FROM 
	olist_raw.order_items
LEFT JOIN olist_raw.products 
	ON olist_raw.order_items.product_id = olist_raw.products.product_id
LEFT JOIN olist_raw.category_name_translation
	ON olist_raw.products.product_category_name = olist_raw.category_name_translation.product_category_name 
WHERE olist_raw.order_items.order_id = {{zamowienie}}
ORDER BY pozycja ASC;