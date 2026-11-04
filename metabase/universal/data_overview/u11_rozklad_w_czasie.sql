-- Rozkład wybranej kolumny z datą w czasie: liczba wierszy w kolejnych miesiącach.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, wymagana), kolumna (Text, domyślnie order_purchase_timestamp, wymagana)
SELECT
	toStartOfMonth(d) AS miesiac,
	count() AS liczba
FROM 
(
	SELECT parseDateTimeBestEffortOrNull(trim(BOTH '"' FROM JSONExtractRaw(formatRowNoNewline('JSONEachRow', *), {{kolumna}}))) AS d
	FROM merge({{baza}}, concat('^', regexpQuoteMeta({{tabela}}), '$'))
	WHERE (SELECT match(type, 'Date') FROM system.columns WHERE database = {{baza}} AND table = {{tabela}} AND name = {{kolumna}})
)
WHERE d IS NOT NULL
GROUP BY miesiac
ORDER BY miesiac;