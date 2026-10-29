-- Lista tabel w bazie danych (uporządkowana po liczbie rekordów malejąco).
SELECT t.name, t.total_rows
FROM system.tables t 
ORDER BY t.total_rows DESC;