-- Histogram wybranej kolumny liczbowej: 20 przedziałów od 1. do 99. percentyla; wartości spoza tego zakresu trafiają do skrajnych przedziałów.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie products, wymagana), kolumna (Text, domyślnie product_weight_g wymagana).
SELECT 
	nr + 1 AS przedzial,
	multiIf(
		nr = 0, concat('< ', toString(round(dol + szer, 2))),
		nr = 19, concat('>= ', toString(round(dol + 19  * szer, 2))),
		concat(toString(round(dol + nr * szer, 2)), ' - ', toString(round(dol + (nr + 1) * szer, 2)))
	) AS zakres,
	count() as liczba
FROM 
(
	SELECT 
		least(greatest(toInt64(floor((x - dol) / szer)), 0), 19) AS nr,
		dol,
		szer
	FROM
	(
		SELECT 
			x,
			quantile(0.01)(x) OVER () AS dol,
			greatest((quantile(0.99)(x) OVER () - quantile(0.01)(x) OVER ()) / 20, 1e-9) AS szer
		FROM 
		(
			SELECT toFloat64OrNull(trim(BOTH '"' FROM JSONExtractRaw(formatRowNoNewline('JSONEachRow', *), {{kolumna}}))) AS x
			FROM merge({{baza}}, concat('^', regexpQuoteMeta({{tabela}}), '$'))
			WHERE (
				SELECT match(type, '^(Nullable\\()?(U?Int(8|16|32|64|128|256)|Float(32|64)|Decimal(32|64|128|256)?\\()')
				FROM system.columns
				WHERE database = {{baza}} AND table = {{tabela}} AND name = {{kolumna}}
			)
		)
		WHERE x IS NOT NULL AND isFinite(x)		
	)
)
GROUP BY nr, dol, szer
ORDER BY nr;