-- Najczęstsze wartości w wybranej kolumnie (Top 10).
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana), kolumna (Text, domyślnie order_status wymagana).
SELECT 
	c.name AS kolumna,
	s.wartosc AS wartosc,
	s.licznosc AS licznosc,
	round(s.udzial_procentowy, 2) AS udzial_procentowy
FROM system.columns as c
INNER JOIN 
(
	SELECT 
		tab.1 AS kolumna,
		tab.2 AS wartosc,
		count() AS licznosc,
		100. * count(*) / sum(count(*)) OVER () AS udzial_procentowy
	FROM merge(
		{{baza}},
		concat('^', regexpQuoteMeta({{tabela}}), '$')
	)
	ARRAY JOIN JSONExtractKeysAndValuesRaw(
		formatRowNoNewline('JSONEachRow', *)
	) as tab
	WHERE tab.1 = {{kolumna}}
	GROUP BY tab.1, tab.2
	ORDER BY licznosc DESC, wartosc ASC
	LIMIT 10
) AS s ON s.kolumna = c.name
WHERE c.database = {{baza}} AND c.table = {{tabela}} AND c.name = {{kolumna}}
ORDER BY s.licznosc DESC, s.wartosc ASC;
