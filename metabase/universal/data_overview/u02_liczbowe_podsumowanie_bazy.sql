-- Liczbowe podsumowanie bazy danych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana)
SELECT 
	count() AS  tabele, 
	sum(t.total_rows) AS rekordy, 
	sum(c.liczba_kolumn) AS kolumny,
	round(sum(t.total_bytes) / 1024 / 1024, 2) AS rozmiar_mb
FROM system.tables AS t
LEFT JOIN 
(
	SELECT database, table, count() AS liczba_kolumn
	FROM system.columns
	GROUP BY database, table
) AS c ON c.database = t.database AND c.table = t.name
WHERE t.database = {{baza}};