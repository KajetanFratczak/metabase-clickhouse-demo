-- Lista kolumn ze szczegółami w danej tabeli w bazie danych.
-- Zmienne: baza (Text, domyślnie olist_raw, wymagana), tabela (Text, domyślnie orders, niewymagana)
SELECT table, position, name, type, comment
FROM system.columns
WHERE database = {{baza}} [[AND table = {{tabela}}]]
ORDER BY table, position;