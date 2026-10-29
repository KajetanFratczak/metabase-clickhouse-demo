-- Uniwersalny profil danej tabeli w bazie danych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana)

-- merge() wybiera tabelę po nazwie podanej w filtrze
-- formatRowNoNewline('JSONEachRow', *) zamienia każdy wiersz na tekst JSON, 
-- a JSONExtractKeysAndValuesRaw rozkłada go na pary (kolumna, wartość). 
-- Dzięki temu jedno GROUP BY liczy statystyki wszystkich kolumn naraz.
SELECT 
	c.position AS lp,
	c.name AS kolumna,
	c.type AS typ,
	coalesce(s.wiersze, 0) AS wiersze,
	coalesce(s.braki, 0) AS braki,
	s.braki / nullIf(s.wiersze, 0) AS udzial_brakow,
	coalesce(s.unikalne, 0) AS unikalne
FROM system.columns AS c
LEFT JOIN 
(
	SELECT 
		tab.1 AS kolumna,
		count() AS wiersze,
		countIf(tab.2 IN ('null', '""')) AS braki,
		uniqExactIf(
			tab.2,
			tab.2 NOT IN ('null', '""')
		) AS unikalne
	FROM merge(
		{{baza}},
		concat('^', regexpQuoteMeta({{tabela}}), '$')
	)
	ARRAY JOIN JSONExtractKeysAndValuesRaw(
		formatRowNoNewline('JSONEachRow', *)
	) as tab
	GROUP BY kolumna
) AS s ON s.kolumna = c.name
WHERE c.database = {{baza}} AND c.table = {{tabela}}
ORDER BY c.position;