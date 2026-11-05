-- Przeglądarka produktów: jedna strona wyników (50 wierszy). Filtry, sortowanie i stronicowanie wykonuje ClickHouse.
-- Zmienne: szukaj (Text), produkt (Text), kategoria (Field Filter: Products -> Product Category Name), waga (Field Filter: Products -> Product Weight G), sortuj (Text, domyślnie kategoria, wymagana), strona (Number, domyślnie 1, wymagana).
-- Sortuj: kategoria (produkty bez kategorii na końcu), ID produktu, najcięższe, najlżejsze; produkty bez wagi na końcu.
WITH coalesce(
	nullIf(olist_raw.category_name_translation.product_category_name_english, ''),
	nullIf(toString(olist_raw.products.product_category_name), ''),
	'(brak kategorii)'
) AS nazwa_kategorii
SELECT
  olist_raw.products.product_id AS product_id,
  nazwa_kategorii AS kategoria,
  olist_raw.products.product_category_name AS kategoria_pt,
  olist_raw.products.product_photos_qty AS zdjecia,
  olist_raw.products.product_weight_g AS waga_g,
  olist_raw.products.product_length_cm AS dlugosc_cm,
  olist_raw.products.product_height_cm AS wysokosc_cm,
  olist_raw.products.product_width_cm AS szerokosc_cm
FROM olist_raw.products
LEFT JOIN olist_raw.category_name_translation
	ON olist_raw.products.product_category_name = olist_raw.category_name_translation.product_category_name
WHERE 1 = 1
	[[AND positionCaseInsensitiveUTF8(concat(olist_raw.products.product_id, ' ', coalesce(olist_raw.products.product_category_name, ''), ' ', nazwa_kategorii), {{szukaj}}) > 0]]
	[[AND {{kategoria}}]]
	[[AND {{waga}}]]
	[[AND olist_raw.products.product_id = {{produkt}}]]
ORDER BY 
	if(
		{{sortuj}} = 'kategoria', nazwa_kategorii = '(brak kategorii)',
		0
	) ASC,
	if(
		{{sortuj}} = 'kategoria', nazwa_kategorii,
		''
	) ASC,
	multiIf (
		{{sortuj}} = 'najlżejsze', toInt64(olist_raw.products.product_weight_g),
		{{sortuj}} = 'najcięższe', -toInt64(olist_raw.products.product_weight_g),
		0
	) ASC NULLS LAST,
	olist_raw.products.product_id ASC
LIMIT 50 OFFSET (toUInt32(greatest({{strona}}, 1)) - 1) * 50;