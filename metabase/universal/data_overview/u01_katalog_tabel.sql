-- Katalog tabel w wybranej bazie danych (uporządkowana po liczbie rekordów malejąco) + kolumny.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana)
SELECT 
	t.name as tabela, 
	t.total_rows as liczba_rekordow, 
	c.liczba_kolumn,
	round(t.total_bytes / 1024 / 1024, 2) AS rozmiar_mb
FROM system.tables t 
LEFT JOIN 
(
	SELECT database, table, count() AS liczba_kolumn
	FROM system.columns
	GROUP BY database, table
) AS c ON c.database = t.database AND c.table = t.name
WHERE t.database = {{baza}}
ORDER BY t.total_rows DESC;