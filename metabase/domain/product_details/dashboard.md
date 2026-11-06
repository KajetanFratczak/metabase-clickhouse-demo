# Szczegóły produktu

## Cel

Osobny dashboard z pełnym widokiem jednego produktu: dane i wymiary,
podsumowanie sprzedaży, sprzedaż w czasie, sprzedawcy oraz zamówienia
zawierające produkt. Otwiera się kliknięciem ID produktu w przeglądarce
produktów i w szczegółach zamówienia, a prowadzi dalej do szczegółów zamówień.

## Karty

| Karta | Pytanie | Wizualizacja | Wiersze |
|---|---|---|---|
| Szczegóły produktu | 43_product_details | Detail | 1 |
| Podsumowanie produktu | 44_product_sales_summary | Detail | 1 |
| Sprzedaż wg miesiąca zakupu | 45_product_sales_over_time | wykres słupkowy, dwie osie | 1 na miesiąc ze sprzedażą |
| Sprzedawcy produktu | 46_product_sellers | Table | 1 na sprzedawcę |
| Zamówienia zawierające produkt | 47_product_orders | Table | 1 na zamówienie |

W pytaniach 46 i 47 najpierw liczę sumy w CTE (po sprzedawcy, po zamówieniu),
a dopiero potem dołączam sprzedawców i zamówienia. Wiersze się nie mnożą
i nie trzeba grupować po kolumnach opisowych.

## Filtr

| Filtr | Zmienna SQL | Konfiguracja | Karty | Domyślnie |
|---|---|---|---|---|
| ID produktu | produkt | Text; na dashboardzie Text or Category → Is, wymagany | 43–47 | aca2eb7d00ea1a7b8ebd4e68314663af |

## Wartości liczone

- sprzedane sztuki — liczba pozycji `order_items` z produktem (jedna sztuka to jedna pozycja),
- wartość produktów, transport i wartość z transportem,
- cena minimalna, maksymalna i średnia — ten sam produkt może mieć różne ceny u różnych sprzedawców,
- pierwsze i ostatnie zamówienie — daty z `orders`,
- średnia ocena zamówień z produktem — opinie dotyczą całych zamówień, nie pojedynczych produktów.

## Nawigacja

| Skąd | Kliknięcie | Dokąd |
|---|---|---|
| Przeglądarka produktów (karta 35) | `product_id` | Szczegóły produktu, ID produktu ← `product_id` |
| Szczegóły zamówienia (karta 38) | `id_produktu` | Szczegóły produktu, ID produktu ← `id_produktu` |
| Zamówienia zawierające produkt (47) | `id_zamowienia` | Szczegóły zamówienia, ID zamówienia ← `id_zamowienia` |
| Karta z linkiem | — | Przeglądarka produktów |

## Produkty testowe

| Produkt | Co sprawdza |
|---|---|
| aca2eb7d00ea1a7b8ebd4e68314663af | domyślny, najczęściej sprzedawany: 527 szt., 431 zamówień, 37 608,90, 1 sprzedawca, 13 miesięcy ze sprzedażą (brak we wrześniu 2017) |
| 99a4788cb24856965c36a24e339b6058 | najwyższy przychód wśród najczęściej sprzedawanych: 488 szt., 43 025,56, 2 sprzedawców |
| d285360f29ac7fd97640bf0baef03de0 | najwięcej sprzedawców (8), ceny 154,91–349,99 |
| 5a848e4ab52fd5445cdc07aab1c40e48 | bez kategorii, 197 szt. |
| 24dea9b9a1d450d96702d46a0a835ff3 | z zamówienia testowego, 1 szt. |

## Materiały

- [Dashboard PDF](../../../docs/dashboards/browser_products_product_details.pdf)
- [Pytanie 43](../../../docs/screenshots/domain/product_details/43_product_details.png)
- [Pytanie 44](../../../docs/screenshots/domain/product_details/44_product_sales_summary.png)
- [Pytanie 45](../../../docs/screenshots/domain/product_details/45_product_sales_over_time.png)
- [Pytanie 46](../../../docs/screenshots/domain/product_details/46_product_sellers.png)
- [Pytanie 47](../../../docs/screenshots/domain/product_details/47_product_orders.png)