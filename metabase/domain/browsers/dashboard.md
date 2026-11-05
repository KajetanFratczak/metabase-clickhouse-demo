# Przeglądarki zamówień, klientów i produktów — paginacja serwerowa

# Przeglądarka zamówień — paginacja serwerowa

## Cel

Przegląd rekordów tabeli `olist_raw.orders` z wyszukiwaniem,
filtrami, sortowaniem i paginacją po stronie ClickHouse.
Jedna strona zawiera maksymalnie 50 rekordów.

Dane klienta (osoba, miasto, stan) pochodzą z `olist_raw.customers`
przez `LEFT JOIN` po `customer_id`. To połączenie 1:1, więc nie
zwielokrotnia zamówień. Kolumna `opoznienie_dni` to liczba dni
między planowaną a faktyczną dostawą (wartość dodatnia oznacza
spóźnienie, ujemna dostawę przed terminem).

## Karty

| Karta | Pytanie | Wizualizacja |
|---|---|---|
| Lista zamówień | 31_orders_paged | Table |
| Podsumowanie i nawigacja | 32_orders_paged_navigation | Table |

Pytanie 32 pokazuje `wyniki`, `stron`, `strona`, `rekordy`
oraz numery stron do przejścia: `pierwsza`, `poprzednia`,
`nastepna`, `ostatnia`.

## Filtry

| Filtr | Zmienna SQL | Konfiguracja | Karty | Domyślnie |
|---|---|---|---|---|
| Data zakupu | data_zakupu | Field Filter → orders.order_purchase_timestamp; filtr daty | 31, 32 | pusty |
| Status | status | Field Filter → orders.order_status; Text or Category → Is | 31, 32 | pusty |
| Stan klienta | stan | Field Filter → customers.customer_state; Location → Is | 31, 32 | pusty |
| Klient (osoba) | osoba | Text; dokładne customer_unique_id | 31, 32 | pusty |
| Szukaj | szukaj | Text; na dashboardzie Text or Category → Is | 31, 32 | pusty |
| Sortuj | sortuj | Text; lista: najnowsze, najstarsze, status, miasto, największe opóźnienie | 31 | najnowsze |
| Strona | strona | Number; pojedyncza dodatnia liczba całkowita | 31, 32 | 1 |

Zmienne `sortuj` i `strona` są wymagane.

Wyszukiwanie obejmuje identyfikator zamówienia, identyfikator
klienta, identyfikator osoby i miasto. Wyszukuje fragment tekstu
bez rozróżniania wielkości liter.

Filtr Klient (osoba) korzysta z `customer_unique_id`, bo
`customer_id` jest kluczem klienta w jednym zamówieniu
i zawsze zwracałby jedno zamówienie.

## Sortowanie

| Opcja | Kolejność |
|---|---|
| najnowsze | data zakupu malejąco, order_id |
| najstarsze | data zakupu rosnąco, order_id |
| status | status, data zakupu malejąco, order_id |
| miasto | miasto klienta, data zakupu malejąco, order_id |
| największe opóźnienie | opóźnienie malejąco, data zakupu malejąco, order_id; zamówienia bez daty dostarczenia na końcu |

Opcja `najnowsze` korzysta z domyślnej gałęzi wyrażeń
sortujących. Końcowy klucz `order_id` zapewnia jednoznaczną
kolejność rekordów.

## Nawigacja i przypadki brzegowe

Tak jak w przeglądarce klientów (niżej): dla kolumn `pierwsza`,
`poprzednia`, `nastepna` i `ostatnia` w karcie 32
Click behavior → Update a dashboard filter → Strona.
Puste pole oznacza brak dostępnego przejścia.
Ostatnia strona (1989) zawiera 41 rekordów.

## Materiały

- [Dashboard PDF](../../../docs/dashboards/browser_orders_paged_paginated.pdf)
- [Pytanie 31](../../../docs/screenshots/domain/browsers/31_orders_paged.png)
- [Pytanie 32](../../../docs/screenshots/domain/browsers/32_orders_paged_navigation.png)

# Przeglądarka klientów — paginacja serwerowa

## Cel

Przegląd rekordów tabeli `olist_raw.customers` z wyszukiwaniem,
filtrami, sortowaniem i paginacją po stronie ClickHouse.
Jedna strona zawiera maksymalnie 50 rekordów.

Jeden wiersz oznacza rekord identyfikowany przez `customer_id`.
Osobę identyfikuje `customer_unique_id`, który może wystąpić
w wielu rekordach.

## Karty

| Karta | Pytanie | Wizualizacja |
|---|---|---|
| Lista klientów | 33_customers_paged | Table |
| Podsumowanie i nawigacja | 34_customers_paged_navigation | Table |

Pytanie 34 pokazuje:
- `wyniki` — liczbę rekordów po filtrach,
- `osoby` — liczbę unikalnych osób po filtrach,
- `stron` — liczbę stron po 50 rekordów,
- `strona` — bieżący numer strony,
- `rekordy` — zakres rekordów albo komunikat,
- `pierwsza`, `poprzednia`, `nastepna`, `ostatnia` — numery stron do przejścia.

Liczbę stron obliczamy na podstawie rekordów, nie unikalnych osób.
Pytanie 28b nie jest potrzebne w tym wariancie dashboardu.

## Filtry

| Filtr | Zmienna SQL | Konfiguracja | Karty | Domyślnie |
|---|---|---|---|---|
| Szukaj | szukaj | Text | 33, 34 | pusty |
| Stan | stan | Field Filter → customers.customer_state | 33, 34 | pusty |
| Miasto | miasto | Field Filter → customers.customer_city; na dashboardzie Text or Category → Is | 33, 34 | pusty |
| Osoba | osoba | Text; dokładne customer_unique_id | 33, 34 | pusty |
| Sortuj | sortuj | Text; lista: miasto, stan, osoba | 33 | miasto |
| Strona | strona | Number; pojedyncza dodatnia liczba całkowita | 33, 34 | 1 |

Zmienne `sortuj` i `strona` są wymagane.

Wyszukiwanie obejmuje identyfikator rekordu, identyfikator osoby,
miasto i prefiks kodu pocztowego. Wyszukuje fragment tekstu
bez rozróżniania wielkości liter.

W tej konfiguracji filtr miasta na dashboardzie korzysta z
Text or Category → Is. Próba podłączenia go jako Location
nie udostępniała zmiennej `miasto`.

## Sortowanie

| Opcja | Kolejność rosnąca |
|---|---|
| miasto | customer_city, customer_unique_id, customer_id |
| stan | customer_state, customer_unique_id, customer_id |
| osoba | customer_unique_id, customer_id |

Opcja `osoba` korzysta z domyślnej gałęzi wyrażenia `multiIf`.
Lista wartości filtra powinna zawierać wyłącznie powyższe opcje.

Końcowy klucz `customer_id` zapewnia jednoznaczną kolejność
rekordów dla niezmienionych danych.

## Nawigacja

Dla każdej z kolumn `pierwsza`, `poprzednia`, `nastepna`
i `ostatnia` w karcie 34 ustaw:

Click behavior → Update a dashboard filter → Strona

Wartością przekazywaną do filtra jest wartość klikniętej kolumny.
Filtr Strona musi być podłączony do obu kart.

Puste pole oznacza brak dostępnego przejścia.

## Przypadki brzegowe

- Brak wyników: jedna pusta strona i komunikat „brak wyników”.
- Ostatnia strona może zawierać mniej niż 50 rekordów.
- SQL nie resetuje numeru strony po zmianie filtrów.
- Numer strony poza zakresem: lista jest pusta, a nawigacja
  wyświetla komunikat i umożliwia powrót.
- Ze strony poza zakresem „Poprzednia” prowadzi na ostatnią
  dostępną stronę.

## Materiały

- [Dashboard PDF](../../../docs/dashboards/browser_customers_paged_paginated.pdf)
- [Pytanie 33](../../../docs/screenshots/domain/browsers/33_customers_paged.png)
- [Pytanie 34](../../../docs/screenshots/domain/browsers/34_customers_paged_navigation.png)

# Przeglądarka produktów — paginacja serwerowa

## Cel

Przegląd rekordów tabeli `olist_raw.products` z wyszukiwaniem,
filtrami, sortowaniem i paginacją po stronie ClickHouse.
Jedna strona zawiera maksymalnie 50 rekordów.

Kolumna `kategoria` pokazuje nazwę angielską z tabeli
`category_name_translation`, a gdy jej brak – portugalską
albo „(brak kategorii)”. Kolumna `kategoria_pt` to oryginalna
nazwa z tabeli `products`.

## Karty

| Karta | Pytanie | Wizualizacja |
|---|---|---|
| Lista produktów | 35_products_paged | Table |
| Podsumowanie i nawigacja | 36_products_paged_navigation | Table |

Pytanie 36 pokazuje `wyniki`, `stron`, `strona`, `rekordy`
oraz numery stron do przejścia: `pierwsza`, `poprzednia`,
`nastepna`, `ostatnia`.

## Filtry

| Filtr | Zmienna SQL | Konfiguracja | Karty | Domyślnie |
|---|---|---|---|---|
| Szukaj | szukaj | Text; na dashboardzie Text or Category → Is | 35, 36 | pusty |
| Produkt | produkt | Text; dokładne product_id | 35, 36 | pusty |
| Kategoria | kategoria | Field Filter → products.product_category_name; Text or Category → Is | 35, 36 | pusty |
| Waga (g) | waga | Field Filter → products.product_weight_g; Number → Between | 35, 36 | pusty |
| Sortuj | sortuj | Text; lista: kategoria, ID produktu, najcięższe, najlżejsze | 35 | kategoria |
| Strona | strona | Number; pojedyncza dodatnia liczba całkowita | 35, 36 | 1 |

Zmienne `sortuj` i `strona` są wymagane.

Wyszukiwanie obejmuje identyfikator produktu, nazwę portugalską
i nazwę wyświetlaną kategorii. Wyszukuje fragment tekstu
bez rozróżniania wielkości liter. Produkty bez kategorii
znajduje wpisanie „brak”.

Filtr Kategoria korzysta z oryginalnych nazw portugalskich
(kolumna źródłowa), więc obejmuje też kategorie bez tłumaczenia,
np. `pc_gamer`.

## Sortowanie

| Opcja | Kolejność rosnąca |
|---|---|
| kategoria | produkty z kategorią przed „(brak kategorii)”, nazwa kategorii, product_id |
| ID produktu | product_id |
| najcięższe | waga malejąco, product_id; produkty bez wagi na końcu |
| najlżejsze | waga rosnąco, product_id; produkty bez wagi na końcu |

Opcja `ID produktu` korzysta z domyślnej gałęzi wyrażeń
sortujących. Końcowy klucz `product_id` zapewnia jednoznaczną
kolejność rekordów.

## Nawigacja i przypadki brzegowe

Tak jak w przeglądarce klientów: dla kolumn `pierwsza`,
`poprzednia`, `nastepna` i `ostatnia` w karcie 36
Click behavior → Update a dashboard filter → Strona.
Puste pole oznacza brak dostępnego przejścia.
Ostatnia strona (660) zawiera jeden rekord.

## Materiały

- [Dashboard PDF](../../../docs/dashboards/browser_products_paged_paginated.pdf)
- [Pytanie 35](../../../docs/screenshots/domain/browsers/35_products_paged.png)
- [Pytanie 36](../../../docs/screenshots/domain/browsers/36_products_paged_navigation.png)