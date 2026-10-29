-- Zakresy dat wybranej tabeli w bazie danych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana)
SELECT kolumna, minimum AS min_data, maksimum AS max_data
FROM (
	-- u04
	SELECT 
		c.position AS lp,
		c.name AS kolumna,
		c.type AS typ,
		coalesce(s.wiersze, 0) AS wiersze,
		coalesce(s.braki, 0) AS braki,
		s.braki / nullIf(s.wiersze, 0) AS udzial_brakow,
		coalesce(s.unikalne, 0) AS unikalne,
		if(match(c.type, 'Int|Float|Decimal'), toString(s.min_liczba), s.min_tekst) AS minimum,
		if(match(c.type, 'Int|Float|Decimal'), toString(s.max_liczba), s.max_tekst) AS maksimum
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
			) AS unikalne,
			minIf(trim(BOTH '"' FROM tab.2), tab.2 NOT IN ('null', '""')) as min_tekst,
			maxIf(trim(BOTH '"' FROM tab.2), tab.2 NOT IN ('null', '""')) as max_tekst,
			min(toFloat64OrNull(trim(BOTH '"' FROM tab.2))) as min_liczba,
			max(toFloat64OrNull(trim(BOTH '"' FROM tab.2))) as max_liczba
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
)
WHERE typ LIKE '%Date%';