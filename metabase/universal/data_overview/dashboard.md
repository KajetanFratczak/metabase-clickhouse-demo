# Przegląd danych (widok uniwersalny)

**Cel:** przegląd dowolnej bazy ClickHouse – tabele, liczba rekordów, kolumny, zakresy dat i braki danych – bez zapisu w bazie (wystarczy uprawnienie SELECT).
**PDF:** [PDF](../../../docs/dashboards/data_overview.pdf)

## Karty

| Karta | Pytanie | Wizualizacja | Rozmiar |
|---|---|---|---|
| Opis | – | Text | 24×2 |
| Tabele / Rekordy / Kolumny / Rozmiar danych | u02_liczbowe_podsumowanie_bazy (Field to show: tabele / rekordy / kolumny / rozmiar_mb) | Number | 4 × (6×3) |
| Katalog tabel | u01_katalog_tabel | Table, mini bar chart przy liczbie rekordów | 24×6 |
| „### Tabela: {{tabela}}” | – | Text, zmienna podłączona do filtra Tabela | 24×1 |
| Profil tabeli | u04_profil_tabeli | Table, udział braków jako procent, formatowanie warunkowe braków | 24×7 |
| Zakresy dat | u05_zakresy_dat_tabeli | Table | 14×7 |
| Braki danych | u06_braki_danych_tabeli | Row | 10×7 |
| Kolumny tabeli | u03_lista_kolumn_tabeli | Table | 24×6 |

## Filtry

| Filtr | Typ | Wartości | Domyślnie | Podłączony do |
|---|---|---|---|---|
| Baza | Text or category | lista z pytania u00_lista_baz (kolumna `baza`) | olist_raw | zmienna `baza` w u01–u06 |
| Tabela | Text or category | lista z pytania u01_katalog_tabel (kolumna `tabela`) | orders | zmienna `tabela` w u03–u06, karta tekstowa |

## Interakcje

- **Katalog tabel:** Click behavior → Update a dashboard filter → Tabela ← kolumna `tabela`.

## Ograniczenia

- Lista wartości filtra „Tabela” pochodzi z pytania u01 uruchomionego dla jego domyślnej bazy – po zmianie bazy tabelę wybiera się kliknięciem w katalogu.
- Karty u04–u06 czytają całą wybraną tabelę przy każdym otwarciu (profil liczony na bieżąco).
- Jeśli przy wyborze źródła wartości filtra Metabase zgłasza „To pytanie nie ma żadnych kolumn tekstowych”, trzeba to zignorować i wpisać ręcznie wartości do wyboru.