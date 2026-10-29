-- Lista kolumn w każdej tabeli w bazie danych.
SELECT 
	t.name as tabela, 
	t.total_rows as liczba_rekordow, 
	c.name as kolumna
FROM system.tables t 
LEFT JOIN 
(
	SELECT database, table, name
	FROM system.columns
) AS c ON c.database = t.database AND c.table = t.name
WHERE t.database = 'olist_raw'
ORDER BY t.total_rows DESC;