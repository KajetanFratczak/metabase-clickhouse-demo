-- Lista baz dostępnych dla użytkownika.
-- Zmienne: brak
SELECT DISTINCT database AS baza
FROM system.tables
WHERE database NOT IN ('system', 'information_schema', 'INFORMATION_SCHEMA')
ORDER BY baza