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