-- Rozkład kategorii: top 10 + pozostałe + braki danych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana), kolumna (Text, domyślnie order_status, wymagana).
WITH liczebnosci AS 
(
	SELECT 
		tab.2 AS wartosc_raw,
		tab.2 IN ('null', '""') AS czy_brak,
		count() AS liczba
 	FROM merge(
		{{baza}},
		concat('^', regexpQuoteMeta({{tabela}}), '$')
	)
	ARRAY JOIN JSONExtractKeysAndValuesRaw(
		formatRowNoNewline('JSONEachRow', *)
	) as tab
	WHERE tab.1 = {{kolumna}}
	GROUP BY tab.2
),
ranking AS 
(
	SELECT 
		wartosc_raw,
		czy_brak,
		liczba,
		row_number() OVER (
			PARTITION BY czy_brak
			ORDER BY liczba DESC, wartosc_raw ASC
		) AS pozycja
	FROM liczebnosci
),
grupy AS 
(
	SELECT 
		multiIf(
			czy_brak = 1, 3,
			pozycja <= 10, 1,
			2
		) AS kolejnosc_grupy,
		multiIf(
			czy_brak = 1, 'Braki danych',
			pozycja <= 10, trim(BOTH '"' FROM wartosc_raw),
			'Pozostałe'
		) AS wartosc,
		sum(liczba) AS liczba
	FROM ranking
	GROUP BY kolejnosc_grupy, wartosc
)
SELECT 
	c.name AS kolumna,
	c.type AS typ,
	s.wartosc AS wartosc,
	s.liczba AS liczba,
	round(100. * s.liczba / nullIf(sum(s.liczba) OVER (), 0), 2) AS udzial_procentowy
FROM system.columns as c
CROSS JOIN grupy AS s
WHERE c.database = {{baza}} AND c.table = {{tabela}} AND c.name = {{kolumna}}
ORDER BY s.kolejnosc_grupy ASC, s.liczba DESC, s.wartosc ASC;