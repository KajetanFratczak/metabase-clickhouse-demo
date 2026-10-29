# Metabase – pytania i dashboardy

Darmowa wersja Metabase nie eksportuje pytań ani dashboardów do plików (funkcja *serialization* jest w wersjach Pro i Enterprise), dlatego repozytorium przechowuje:

- **SQL każdego pytania** (`*.sql`) – dla pytań z edytora wizualnego jest to SQL wygenerowany przez Metabase („View the SQL”), dla pytań SQL ich treść; nagłówek pliku opisuje zmienne,
- **opis każdego dashboardu** (`dashboard.md`) – karty, filtry i interakcje potrzebne do odtworzenia.

## Struktura

- `domain/` – widoki na danych testowych Olist: `sales_performance/` (pytania 00–24) i `browsers/` (przeglądarki rekordów, 25–36),
- `universal/` – widoki niezależne od domeny, działające dla każdej bazy ClickHouse: `data_overview/` (u00–u06).
- `universal/robocze/` – zapytania robocze z etapu poznawania tabel systemowych (nieużywane na dashboardach).

## Odtworzenie pytania

- **pytanie SQL:** + New → SQL query → wklej treść → odpowiednio ustaw zmienne → Save,
- **pytanie z edytora wizualnego:** zbuduj je ponownie w edytorze na podstawie SQL; wklejenie SQL też zadziała, ale pytanie straci drillthrough i kartę rekordu.