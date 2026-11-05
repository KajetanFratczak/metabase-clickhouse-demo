-- Nawigacja przeglądarki klientów: liczba wyników, osób i stron, zakres rekordów na stronie, numery stron do przejścia (kliknięcie ustawia filtr Strona).
-- Puste pole oznacza przejście niedostępne, np. Następna na ostatniej stronie.
-- Zmienne: jak w 33_customers_paged, bez sortuj (kolejność nie zmienia liczby wyników).
WITH toUInt32(greatest({{strona}}, 1)) AS nr
SELECT 
	wyniki,
	osoby,
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
	SELECT	
		count() AS wyniki,
		uniqExact(olist_raw.customers.customer_unique_id) AS osoby,
		greatest(intDiv(count() + 49, 50), 1) AS stron
	FROM olist_raw.customers
	WHERE 1 = 1
		[[AND positionCaseInsensitiveUTF8(concat(olist_raw.customers.customer_id, ' ', olist_raw.customers.customer_unique_id, ' ', olist_raw.customers.customer_city, ' ', olist_raw.customers.customer_zip_code_prefix), {{szukaj}}) > 0]]
		[[AND {{stan}}]]
		[[AND {{miasto}}]]
		[[AND olist_raw.customers.customer_unique_id = {{osoba}}]]
);