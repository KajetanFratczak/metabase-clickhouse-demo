-- Najrzadsze niepuste wartości w wybranej kolumnie.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie products, wymagana), kolumna (Text, domyślnie product_category_name, wymagana).

WITH wartosci AS
(
	SELECT JSONExtractRaw(
		formatRowNoNewline('JSONEachRow', *),
		{{kolumna}}
	) AS surowa
	FROM merge(
		{{baza}},
		concat('^', regexpQuoteMeta({{tabela}}), '$')
	)
)
SELECT 
	trim(BOTH '"' FROM surowa) AS wartosc,
	count() AS liczba,
	round(100. * count() / nullIf(sum(count()) OVER (), 0), 2) AS udzial_wsrod_niepustych_procent
FROM wartosci 
WHERE surowa NOT IN ('null', '""', '')
GROUP BY surowa
ORDER BY liczba ASC, toFloat64OrNull(wartosc) ASC, wartosc ASC
LIMIT 10;