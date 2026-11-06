-- Szczegóły produktu: kategoria (angielska i portugalska), zdjęcia, waga i wymiary. Wizualizacja Detail.
-- Zmienne: produkt (Text, wymagana, domyślnie aca2eb7d00ea1a7b8ebd4e68314663af).
WITH coalesce(
	nullIf(olist_raw.category_name_translation.product_category_name_english, ''),
	nullIf(toString(olist_raw.products.product_category_name), ''),
	'(brak kategorii)'
) AS nazwa_kategorii
SELECT
	olist_raw.products.product_id AS id_produktu,
	nazwa_kategorii AS kategoria,
	olist_raw.products.product_category_name AS kategoria_pt,
	olist_raw.products.product_photos_qty AS zdjecia,
	olist_raw.products.product_weight_g AS waga_g,
	olist_raw.products.product_length_cm AS dlugosc_cm,
	olist_raw.products.product_width_cm AS szerokosc_cm,
	olist_raw.products.product_height_cm AS wysokosc_cm
FROM 
	olist_raw.products
LEFT JOIN olist_raw.category_name_translation
	ON olist_raw.products.product_category_name = olist_raw.category_name_translation.product_category_name
WHERE olist_raw.products.product_id = {{produkt}};