-- Wartości powtarzające się w wybranej kolumnie.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie customers, wymagana), kolumna (Text, domyślnie customer_unique_id, wymagana).

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
	count() - 1 AS nadmiarowe_wystapienia
FROM wartosci 
WHERE surowa NOT IN ('null', '""', '')
GROUP BY surowa
HAVING count() > 1
ORDER BY liczba DESC, toFloat64OrNull(wartosc) ASC, wartosc ASC
LIMIT 100;