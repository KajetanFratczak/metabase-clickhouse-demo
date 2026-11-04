-- Podsumowanie wybranej kolumny: liczba wierszy, braki, wartości niepuste, liczba różnych wartości i udział unikalnych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana), kolumna (Text, domyślnie order_status wymagana).
SELECT 
	c.name AS kolumna,
	c.type AS typ,
	s.wiersze AS wiersze,
	s.braki AS braki,
	s.niepuste AS niepuste,
	s.unikalne AS unikalne,
	round(100. * s.unikalne / nullIf(s.niepuste, 0), 2) AS udzial_unikalnych_procent
FROM system.columns as c
CROSS JOIN 
(
	SELECT 
		count() AS wiersze,
		countIf(tab.2 IN ('null', '""')) AS braki,
		countIf(tab.2 NOT IN ('null', '""')) AS niepuste,
		uniqExactIf(tab.2, tab.2 NOT IN ('null', '""')) AS unikalne
 	FROM merge(
		{{baza}},
		concat('^', regexpQuoteMeta({{tabela}}), '$')
	)
	ARRAY JOIN JSONExtractKeysAndValuesRaw(
		formatRowNoNewline('JSONEachRow', *)
	) as tab
	WHERE tab.1 = {{kolumna}}
) AS s
WHERE c.database = {{baza}} AND c.table = {{tabela}} AND c.name = {{kolumna}};