# Metabase – pytania i dashboardy

Darmowa wersja Metabase nie eksportuje pytań ani dashboardów do plików (funkcja *serialization* jest w wersjach Pro i Enterprise), dlatego repozytorium przechowuje:

- **SQL każdego pytania** (`*.sql`) – dla pytań z edytora wizualnego jest to SQL wygenerowany przez Metabase („View the SQL”), dla pytań SQL ich treść; nagłówek pliku opisuje zmienne,
- **opis każdego dashboardu** (`dashboard.md`) – karty, filtry i interakcje potrzebne do odtworzenia.

## Struktura

- `domain/` — widoki na danych testowych Olist:
  - `sales_performance/` — pytania 00–24,
  - `browsers/` — pierwotne przeglądarki 25–30 i 28b, paginacja serwerowa zamówień 31–32, klientów 33–34 i produktów 35–36; konfiguracja kart, filtrów i nawigacji w [opisie dashboardów](domain/browsers/dashboard.md),
- `universal/` – widoki niezależne od domeny, działające dla każdej bazy ClickHouse: `data_overview/` – poziom bazy i tabeli (u00–u06) oraz wybranej kolumny (u08–u14),
- `universal/robocze/` – zapytania robocze z etapu poznawania tabel systemowych i pierwsza wersja najczęstszych wartości (u07), nieużywane na dashboardach.

## Odtworzenie pytania

- **pytanie SQL:** + New → SQL query → wklej treść → odpowiednio ustaw zmienne → Save,
- **pytanie z edytora wizualnego:** zbuduj je ponownie w edytorze na podstawie SQL; wklejenie SQL też zadziała, ale pytanie straci drillthrough i kartę rekordu.