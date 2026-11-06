# Szczegóły zamówienia

## Cel

Osobny dashboard z pełnym widokiem jednego zamówienia: daty i wskaźniki
dostawy, podsumowanie wartości, produkty, płatności i opinie.
Otwiera się kliknięciem ID zamówienia w przeglądarce zamówień
i prowadzi dalej do produktu oraz do pozostałych zamówień tej samej osoby.

## Karty

| Karta | Pytanie | Wizualizacja | Wiersze |
|---|---|---|---|
| Szczegóły zamówienia | 37_order_details | Detail | 1 |
| Podsumowanie zamówienia | 41_order_totals | Detail | 1 |
| Przejdź do osoby | 42_order_person_navigation | Table | 1 |
| Produkty z zamówienia | 38_order_items | Table | 0–N, jedna sztuka to jeden wiersz |
| Płatności za zamówienie | 39_order_payments | Table | 0–N |
| Opinie z zamówienia | 40_order_reviews | Table | 0–N |

Karta 42 służy do nawigacji: kliknięcie ustawiane dla pojedynczej kolumny
działa tylko w kartach typu Table.

## Filtr

| Filtr | Zmienna SQL | Konfiguracja | Karty | Domyślnie |
|---|---|---|---|---|
| ID zamówienia | zamowienie | Text; na dashboardzie Text or Category → Is, wymagany | 37–42 | fb662b5ba362e72d75d486ca4d29c9e4 |

## Wartości liczone

- `czas_dostawy` — dni od zakupu do dostarczenia,
- `opoznienie_dni` — dni od planowanej do faktycznej dostawy (wartość dodatnia oznacza spóźnienie),
- `wartosc_z_transportem` — cena z transportem, dla pozycji i dla całego zamówienia,
- `roznica` — suma płatności minus wartość z transportem; dodatnia: zapłacono więcej
  (np. przy płatności ratalnej), ujemna: mniej; kilka groszy to zaokrąglenia w danych.

## Nawigacja

| Skąd | Kliknięcie | Dokąd |
|---|---|---|
| Przeglądarka zamówień (karta 31) | `order_id` | Szczegóły zamówienia, ID zamówienia ← `order_id` |
| Produkty z zamówienia (38) | `id_produktu` | Szczegóły produktu, ID produktu ← `id_produktu` |
| Przejdź do osoby (42) | `osoba` | Przeglądarka zamówień, Klient (osoba) ← `osoba` |
| Karta z linkiem | — | Przeglądarka zamówień |

Przy przejściu przez Go to custom destination filtry dashboardu docelowego,
których nie podłączono, dostają wartości domyślne (np. Strona = 1).
Link powrotny otwiera listę bez parametrów, więc Metabase przywraca ostatnio
użyte filtry i stronę (`MB_DASHBOARDS_SAVE_LAST_USED_PARAMETERS`, domyślnie włączone).

## Zamówienia testowe

| Zamówienie | Co sprawdza |
|---|---|
| fb662b5ba362e72d75d486ca4d29c9e4 | domyślne: 3 pozycje, płatności karta + voucher, 1 opinia, opóźnienie 11 dni, różnica 0 |
| 8272b63d03f5f79c56e9e4120aec44ef | 21 pozycji (3 produkty), różnica −0,06 |
| fa65dad1b0e818e3ccc5cb0e39231352 | 29 płatności voucher, razem 457,99 |
| 03c939fd7fd3b38f8485a0f95798f1f6 | 3 opinie |
| 7806407a20e7d38caef6b35ea7757142 | anulowane, brak przekazania i dostarczenia |
| 0010dedd556712d7bb69a19cb7bbd37a | brak pozycji |
| bfbd0f9bdef84302105ad712db648a6c | brak płatności, różnica −143,46 |
| d3582fd5ccccd9cb229a63dfb417c86f | osoba z 17 zamówieniami |

## Materiały

- [Dashboard PDF](../../../docs/dashboards/browser_orders_order_details.pdf)
- [Pytanie 37](../../../docs/screenshots/domain/order_details/37_order_details.png)
- [Pytanie 38](../../../docs/screenshots/domain/order_details/38_order_items.png)
- [Pytanie 39](../../../docs/screenshots/domain/order_details/39_order_payments.png)
- [Pytanie 40](../../../docs/screenshots/domain/order_details/40_order_reviews.png)
- [Pytanie 41](../../../docs/screenshots/domain/order_details/41_order_totals.png)
- [Pytanie 42](../../../docs/screenshots/domain/order_details/42_order_person_navigation.png)