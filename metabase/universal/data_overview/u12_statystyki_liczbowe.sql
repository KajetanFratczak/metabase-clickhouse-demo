-- Statystyki wybranej kolumny liczbowej.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie products, wymagana), kolumna (Text, domyślnie product_weight_g, wymagana)

WITH wartosci AS
(
	SELECT toFloat64OrNull(trim(BOTH '"' FROM JSONExtractRaw(formatRowNoNewline('JSONEachRow', *), {{kolumna}}))) AS x
	FROM merge({{baza}}, concat('^', regexpQuoteMeta({{tabela}}), '$'))
	WHERE 
	(
		SELECT match(
			type, 
			'^(Nullable\\()?(U?Int(8|16|32|64|128|256)|Float(32|64)|Decimal(32|64|128|256)?\\()'
		) 
		FROM system.columns 
		WHERE database = {{baza}} AND table = {{tabela}} AND name = {{kolumna}}
	)
),
statystyki AS 
(
	SELECT 
		count() AS liczba_wartosci,
		min(x) AS minimum,
		max(x) AS maksimum,
		avg(x) AS srednia,
		quantilesExact(0.25, 0.50, 0.75, 0.95)(x) AS kwantyle
	FROM wartosci
	WHERE x IS NOT NULL AND isFinite(x)
)
SELECT
	{{kolumna}} AS kolumna,
	liczba_wartosci,
	minimum,
	maksimum,
	srednia,
	kwantyle[1] AS kwartyl_1,
	kwantyle[2] AS mediana,
	kwantyle[3] AS kwartyl_3,
	kwantyle[4] AS percentyl_95,
	kwantyle[3] - kwantyle[1] AS rozstep_miedzykwartylowy
FROM statystyki
WHERE liczba_wartosci > 0;