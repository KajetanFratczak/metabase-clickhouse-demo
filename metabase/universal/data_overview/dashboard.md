# Przegląd danych (widok uniwersalny)

**Cel:** przegląd dowolnej bazy ClickHouse – tabele, liczba rekordów, kolumny, zakresy dat, braki danych i rozkłady wartości wybranej kolumny – bez zapisu w bazie (wystarczy uprawnienie SELECT).

Pytania `u00` - `u06` działają na poziomie bazy i tabeli, `u08` - `u14` na poziomie wybranej kolumny (`u07` to wersja robocza w `../robocze/`).

**PDF:** 
- wersja 2 – z rozkładami wartości, ten sam dashboard dla różnych kolumn:
  - [kolumna tekstowa: orders → order_status](../../../docs/dashboards/data_overview_v2_order_status.pdf)
  - [kolumna liczbowa: products → product_weight_g](../../../docs/dashboards/data_overview_v2_product_weight_g.pdf)
  - [kolumna z brakami: reviews → review_comment_title](../../../docs/dashboards/data_overview_v2_review_comment_title.pdf)
- [wersja 1 – bez rozkładów wartości](../../../docs/dashboards/data_overview_v1.pdf) 

## Karty

| Karta | Pytanie | Wizualizacja | Rozmiar |
|---|---|---|---|
| Opis | – | Text | 24×2 |
| Tabele / Rekordy / Kolumny / Rozmiar (MB) | u02_liczbowe_podsumowanie_bazy (Field to show: tabele / rekordy / kolumny / rozmiar_mb) | Number | 4 × (6×3) |
| „Tabele w bazie” | – | Heading | 24×1 |
| Katalog tabel | u01_katalog_tabel | Table, mini bar chart przy liczbie rekordów | 24×7 |
| „### Tabela: {{tabela}}” | – | Text, zmienna podłączona do filtra Tabela | 24×1 |
| Profil tabeli | u04_profil_tabeli | Table, udział braków jako procent, formatowanie warunkowe braków | 24×7 |
| Zakresy dat tabeli | u05_zakresy_dat_tabeli | Table | 14×7 |
| Braki danych tabeli | u06_braki_danych_tabeli | Row | 10×7 |
| Lista kolumn tabeli | u03_lista_kolumn_tabeli | Table | 24×6 |
| „### Kolumna: {{kolumna}}” | – | Text, zmienna podłączona do filtra Kolumna | 24×1 |
| Podsumowanie kolumny | u08_podsumowanie_kolumny | Detail | 24×4 |
| Rozkład wartości | u09_rozklad_kategorii | Row | 12×8 |
| Statystyki liczbowe | u12_statystyki_liczbowe | Table, ukryta przy braku wyników | 12×8 |
| Histogram | u10_histogram | Bar, ukryta przy braku wyników | 12×8 |
| Rozkład w czasie | u11_rozklad_w_czasie | Line, ukryta przy braku wyników | 12×8 |
| Powtarzające się wartości | u13_powtarzajace_sie_wartosci | Table, ukryta przy braku wyników | 12×8 |
| Najrzadsze wartości | u14_najrzadsze_wartosci | Table | 12×8 |

## Filtry

| Filtr | Typ | Wartości | Domyślnie | Podłączony do |
|---|---|---|---|---|
| Baza | Text or category | lista z pytania u00_lista_baz (kolumna `baza`) | olist_raw | zmienna `baza` w u01–u14 |
| Tabela | Text or category | lista z pytania u01_katalog_tabel (kolumna `tabela`) | orders | zmienna `tabela` w u03–u14, karta „Tabela” |
| Kolumna | Text or category | pole tekstowe, zwykle ustawiane kliknięciem w profil tabeli | order_status | zmienna `kolumna` w u08–u14, karta „Kolumna” |

## Interakcje

- **Katalog tabel:** Click behavior → Update a dashboard filter → Tabela ← kolumna `tabela`.
- **Profil tabeli:** Click behavior → Update a dashboard filter → Kolumna ← kolumna `kolumna`.

## Ograniczenia

- Lista wartości filtra „Tabela” pochodzi z pytania u01 uruchomionego dla jego domyślnej bazy – po zmianie bazy tabelę wybiera się kliknięciem w katalogu.
- Karty profilu (u04–u06) i rozkładów (u08–u14) czytają wybraną tabelę przy każdym otwarciu – wartości są liczone na bieżąco.
- Po zmianie tabeli filtr „Kolumna” zachowuje poprzednią wartość – jeśli takiej kolumny nie ma w nowej tabeli, karty rozkładu są puste do czasu kliknięcia kolumny w profilu.
- Karta „Powtarzające się wartości” ma sens głównie dla kolumn, które powinny być unikalne (np. identyfikatory) – dla kolumn o niewielu wartościach pokazuje po prostu wszystkie wartości.
- Udziały w u08, u09 i u14 są w procentach (0–100) i mają na kartach przyrostek „%”; udziały w u04 i u06 są ułamkami (0–1) w stylu Percent.
- Histogram dzieli zakres od 1. do 99. percentyla na 20 równych przedziałów – przy rozkładach z długim ogonem (np. `product_weight_g`) większość wartości trafia do pierwszego przedziału.