-- Nawigacja przeglądarki produktów: liczba wyników i stron, zakres rekordów na stronie, numery stron do przejścia (kliknięcie ustawia filtr Strona).
-- Puste pole oznacza przejście niedostępne, np. Następna na ostatniej stronie.
-- Zmienne: jak w 35_products_paged, bez sortuj (kolejność nie zmienia liczby wyników).
WITH toUInt32(greatest({{strona}}, 1)) AS nr
SELECT 
	wyniki,
	stron,
	nr AS strona,
	multiIf(
		wyniki = 0, 'brak wyników',
		nr > stron, 'strona poza zakresem - kliknij << Pierwsza',
		concat(toString((nr - 1) * 50 + 1), '-', toString(least(nr * 50, wyniki)))
	) AS rekordy,
	if(nr > 1, 1, NULL) AS pierwsza,
	if(nr > 1, least(nr - 1, stron), NULL) AS poprzednia,
	if(nr < stron, nr + 1, NULL) AS nastepna,
	if(nr != stron, stron, NULL) AS ostatnia
FROM 
(
	WITH coalesce(
		nullIf(olist_raw.category_name_translation.product_category_name_english, ''),
		nullIf(toString(olist_raw.products.product_category_name), ''),
		'(brak kategorii)'
	) AS nazwa_kategorii
	SELECT	
		count() AS wyniki,
		greatest(intDiv(count() + 49, 50), 1) AS stron
	FROM olist_raw.products
	LEFT JOIN olist_raw.category_name_translation
		ON olist_raw.products.product_category_name = olist_raw.category_name_translation.product_category_name
	WHERE 1 = 1
		[[AND positionCaseInsensitiveUTF8(concat(olist_raw.products.product_id, ' ', coalesce(olist_raw.products.product_category_name, ''), ' ', nazwa_kategorii), {{szukaj}}) > 0]]
		[[AND {{kategoria}}]]
		[[AND {{waga}}]]
		[[AND olist_raw.products.product_id = {{produkt}}]]
);