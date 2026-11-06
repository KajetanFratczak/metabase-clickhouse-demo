# Notatki projektowe – Metabase + ClickHouse

Sekcje 1–7: etap 1 (14–15.10.2026) – środowisko, dane testowe Olist i dashboard Sales Performance.
Sekcja 8: etap 2 (od 27.10.2026) – uniwersalne widoki i praca z dużymi zbiorami danych.

## 1. Uruchomienie środowiska

Utworzyłem `docker-compose.yml` z trzema usługami:

- ClickHouse — dane do analizy.
- Metabase — wizualizacje i dashboardy.
- PostgreSQL — konfiguracja, użytkownicy i zapisane obiekty Metabase.

Hasła są w lokalnym `.env`. Wzór ustawień znajduje się w `.env.example`.

Sprawdzenie konfiguracji i uruchomienie:

```powershell
docker compose -f docker-compose.yml config --quiet
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml ps
```

Metabase: http://localhost:3000.

Materiały źródłowe:

- https://numlytics.com/blog/clickhouse-metabase-docker-setup-guide/
- https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker

## 2. Połączenie Metabase z ClickHouse

W Metabase dodaję połączenie:

- Host: `clickhouse`.
- Port: `8123`.
- Użytkownik do odczytu: `demo_reader`.
- Baza: `olist_raw`.

Pojawił się błąd `Invalid LZ4 magic byte: '-112'` (Metabase v0.64.2.2, ClickHouse 26.9.18.11). W **Additional JDBC connection string options / Dodatkowe opcje połączenia JDBC** trzeba było ustawić:

```text
compress=false
```

Po zmianie połączenie działa.

Konto do odczytu tworzę jako administrator ClickHouse:

```sql
CREATE USER IF NOT EXISTS demo_reader
IDENTIFIED WITH sha256_password BY '<własne_hasło>';

GRANT SELECT ON olist_raw.* TO demo_reader;
```

Początkowo nadałem dostęp do `analytics.*`. Po utworzeniu `olist_raw` trzeba było nadać dostęp również do tej bazy.

## 3. Przygotowanie danych

Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

**Brazilian E-Commerce Public Dataset by Olist** — około 100 tys. zamówień z lat 2016–2018. Dane dotyczą sprzedaży, płatności, dostaw, produktów, klientów i opinii.

Jedno zamówienie może mieć wiele pozycji od różnych sprzedawców.

Pliki CSV umieściłem w `data/olist/`:

- `olist_orders_dataset.csv` — zamówienia, statusy i terminy dostaw.
- `olist_order_items_dataset.csv` — pozycje zamówień, ceny i koszty transportu.
- `olist_customers_dataset.csv` — klienci i lokalizacja.
- `olist_products_dataset.csv` — kategorie i cechy produktów.
- `product_category_name_translation.csv` — angielskie nazwy kategorii.
- `olist_order_payments_dataset.csv` — płatności.
- `olist_order_reviews_dataset.csv` — oceny klientów.
- `olist_sellers_dataset.csv` — sprzedawcy.
- `olist_geolocation_dataset.csv` — współrzędne.

Najpierw tworzę bazę:

```sql
CREATE DATABASE IF NOT EXISTS olist_raw;
```

Przykład tabeli i importu:

```sql
CREATE TABLE IF NOT EXISTS olist_raw.orders
(
    order_id String,
    customer_id String,
    order_status LowCardinality(String),
    order_purchase_timestamp DateTime,
    order_approved_at Nullable(DateTime),
    order_delivered_carrier_date Nullable(DateTime),
    order_delivered_customer_date Nullable(DateTime),
    order_estimated_delivery_date DateTime
)
ENGINE = MergeTree
ORDER BY (order_purchase_timestamp, order_id);

INSERT INTO olist_raw.orders
SELECT * FROM file('olist/olist_orders_dataset.csv', 'CSVWithNames');
```

`LowCardinality` stosuję m.in. do statusów, które mają niewiele różnych wartości. `Nullable` pozwala zachować brak daty.

Skrypty znajdują się w `sql/`. Zaczynam od `create_database.sql`. Obecne skrypty importu wykonują `TRUNCATE` przed załadowaniem CSV — ponowne uruchomienie zastępuje zawartość tabeli.

Kontrola importu:

```sql
SELECT name, total_rows
FROM system.tables
WHERE database = 'olist_raw'
ORDER BY name;
```

Załadowałem dziewięć tabel. Tabela `orders` ma 99 441 wierszy.

## 4. Metadane w Metabase

Przechodzę do **Data Studio**, gdzie edytuję metadane tabel i kolumn.

Dla `payments.payment_value`, `order_items.price` i `order_items.freight_value` ustawiam prezentację waluty **Brazilian Real (BRL)**.

Pola `state` oznaczam jako stan, a `city` jako miasto. W geolokalizacji `lat` to **Latitude**, a `lng` to **Longitude**. Część metadanych ustawiła się automatycznie.

Następnie ustawiam klucze encji dla unikalnych identyfikatorów: `orders.order_id`, `customers.customer_id`, `products.product_id`, `sellers.seller_id`.

W `order_items` i `payments` sam `order_id` nie jest unikalny, więc nie ustawiam go jako klucza encji.

Klucze obce, m.in.:

- `orders.customer_id` -> `customers.customer_id`.
- `order_items.order_id` -> `orders.order_id`.
- `order_items.product_id` -> `products.product_id`.
- `order_items.seller_id` -> `sellers.seller_id`.
- `payments.order_id` i `reviews.order_id` -> `orders.order_id`.

Utworzyłem kolekcję **Prototyp – pulpit główny**, a w niej dwie podkolekcje: **Pytania** i **Dashboardy**.

## 5. Pomysły na Dashboardy

Myśląc nad tym, jak ma wyglądać Pulpit Główny - wymyśliłem, że będzie posiadał odnośniki do 4 różnych Dashboardów.
Każdy Dashboard będzie odpowiadał na inne pytania z analizy danych dla różnych potencjalnych użytkowników.

Dashboardy:
- **#1 Financial Analyst** - Sales Performance (Wartość produktów, liczba zamówień, średnia wartość zamówienia, trendy i rankingi sprzedawców, kategorii oraz miast)
- **#2 Expansion Team** - Market Opportunities (Geograficzny rozkład zakupów, zmiany sprzedaży, średni koszyk, terminy i koszty dostaw)
- **#3 Sellers Feedback** - Seller Performance (Wyniki wybranego sprzedawcy, najlepiej sprzedające się produkty, trendy i problemy z realizacją)
- **#4 Customer Recommendations** - Product Discovery (Przegląd kategorii i produktów, popularność, historyczne ceny i oceny powiązanych zamówień)

Zrealizowany został dashboard #1. Po informacji zwrotnej prace przeszły na uniwersalne widoki niezależne od domeny (sekcja 8).

## 6. Rozwiązania małych problemów

Aby dodać mapę Brazylii i wyświetlać stany w Brazylii - musiałem przejść do panelu admina i w pasku po lewej stronie dodać nową mapę korzystając z zakładki Maps.

- https://raw.githubusercontent.com/codeforgermany/click_that_hood/main/public/data/brazil-states.geojson

sigla jako identyfikator regionu oraz name jako nazwa regionu

Aby dodać filtry, zrobiłem joiny w pytaniach 00, 01, 02, 03, 10, 11 (Join Customers). 05, 06, 22, 23, 24 (Join Orders + Join Customers). 

## 7. Dashboard Sales Performance – wersje

- [Wersja 1 (PDF)](dashboards/sales_performance_v1.pdf)
- [Wersja 2 (PDF)](dashboards/sales_performance_v2.pdf)

## 8. Etap 2 – uniwersalne widoki

Zakres prac: zestaw widoków niezależnych od domeny – przegląd danych, lista rekordów, widok rekordu, nawigacja po powiązaniach, jakość danych i podstawowe wskaźniki – oraz sprawdzenie ich działania przy dużej liczbie rekordów.

### 8.1. Wzorzec: lista rekordów

Przygotowałem przeglądarki zamówień, klientów i produktów.

Każda składa się z:
1. pytania z listą rekordów,
2. pytania z liczbą wyników,
3. dashboardu z filtrami podłączonymi do obu kart.

W pytaniu listy wybieram najważniejsze kolumny i ustawiam sortowanie. Dodaję też kolumnę `Szukaj`, która łączy kilka pól tekstowych i pozwala wyszukiwać po nich jednym filtrem.

Połączenia z innymi tabelami dodaję wtedy, gdy potrzebuję ich kolumn do wyświetlania lub filtrowania.

Kolejną przeglądarkę przygotowuję na podstawie tego samego układu: duplikuję dashboard, podmieniam karty i ponownie podłączam filtry.

| Przeglądarka | Pytania | Filtry | Wydruk |
|---|---|---|---|
| Zamówienia — pierwotna | 25, 26 | Szukaj, data zakupu, status, stan klienta, ID klienta | [PDF](dashboards/browser_orders.pdf), [wersja ze stronicowaniem tabeli](dashboards/browser_orders_paged.pdf) |
| Zamówienia — paginacja serwerowa | 31, 32 | Szukaj, data zakupu, status, stan, osoba, sortuj, strona | [PDF](dashboards/browser_orders_paged_paginated.pdf) |
| Klienci — pierwotna | 27, 28, 28b | Szukaj, stan, miasto | [PDF](dashboards/browser_customers.pdf), [wersja ze stronicowaniem tabeli](dashboards/browser_customers_paged.pdf) |
| Klienci — paginacja serwerowa | 33, 34 | Szukaj, stan, miasto, osoba, sortuj, strona | [PDF](dashboards/browser_customers_paged_paginated.pdf) |
| Produkty — pierwotna | 29, 30 | Szukaj, kategoria, waga | [PDF](dashboards/browser_products.pdf), [wersja ze stronicowaniem tabeli](dashboards/browser_products_paged.pdf) |
| Produkty — paginacja serwerowa | 35, 36 | Szukaj, produkt, kategoria, waga, sortuj, strona | [PDF](dashboards/browser_products_paged_paginated.pdf) |

W wariancie klientów z paginacją serwerową pytanie 34 podaje zarówno liczbę rekordów (`wyniki`), jak i liczbę unikalnych osób (`osoby`) po zastosowaniu filtrów. Osobna karta 28b nie jest potrzebna w tym wariancie.

Konfiguracja dashboardów zamówień, klientów i produktów: [karty, filtry i nawigacja](../metabase/domain/browsers/dashboard.md).

**Co ustaliłem podczas pracy:**
- Lista i licznik powinny reagować na te same filtry. Najłatwiej zacząć od duplikatu pytania listy i zmienić podsumowanie na liczbę wierszy.
- Licznik nie musi wyświetlać tych samych kolumn co lista. Ważne, żeby obejmował ten sam zbiór rekordów.
- Przy połączeniach sprawdzam, czy jeden rekord nie pojawia się kilka razy.
- Brakujące wartości z połączonych tabel obsługuję przed połączeniem tekstu, np. przez `coalesce`. W przeciwnym razie całe `concat` może zwrócić `NULL`.
- Kolumnę `Szukaj` zostawiam do filtrowania, ale ukrywam ją w widocznej tabeli.
- Dla filtrów z listą rozwijaną korzystam przede wszystkim z kolumn źródłowych.
- Ustawiam jednoznaczne sortowanie. Jeżeli pierwsza kolumna może się powtarzać, dodaję identyfikator rekordu jako drugie sortowanie.

### 8.2. Ustalenia

**Paginacja:** wcześniejsze warianty przeglądarek korzystają ze stronicowania wyników w tabeli Metabase. Pytania 31–32 (zamówienia), 33–34 (klienci) i 35–36 (produkty) realizują paginację po stronie ClickHouse przez `LIMIT 50 OFFSET ...`. Zmiana filtra `strona` powoduje pobranie wskazanej strony wyników.

Pytania 32, 34 i 36 pokazują liczbę wyników i stron, zakres rekordów oraz numery stron do nawigacji. Lista i nawigacja mają te same warunki filtrowania. Parametr `sortuj` dotyczy tylko listy.

Przy braku wyników nawigacja pokazuje jedną pustą stronę i komunikat „brak wyników”. Jeżeli po zmianie filtrów numer strony przekracza liczbę dostępnych stron, pojawia się komunikat z możliwością powrotu na pierwszą stronę. Numer strony nie jest automatycznie resetowany przez SQL.

**Widok rekordu i powiązania:** zgodnie z ustaleniem z p. Anną szczegóły rekordu pokazuje osobny dashboard. Pierwszy jest **Szczegóły zamówienia** (pytania 37–42): dane z datami i wskaźnikami dostawy, podsumowanie wartości, produkty, płatności i opinie. Każda sekcja to osobne pytanie, żeby wiersze się nie mnożyły. Dashboard otwiera się kliknięciem ID zamówienia w przeglądarce zamówień (Go to custom destination), a dalej prowadzi do produktu (przeglądarka produktów z filtrem Produkt) i do pozostałych zamówień tej samej osoby. Link powrotny otwiera listę z ostatnio użytymi filtrami i stroną. W pierwotnych przeglądarkach (25–30) nadal działa wbudowana karta rekordu Metabase. Konfiguracja: [opis dashboardu](../metabase/domain/order_details/dashboard.md).

**Szczegóły produktu** (pytania 43–47): dane i wymiary, podsumowanie sprzedaży, sprzedaż wg miesięcy, sprzedawcy i zamówienia z produktem. Dashboard otwiera się kliknięciem ID produktu w przeglądarce produktów i w szczegółach zamówienia, a lista zamówień prowadzi z powrotem do szczegółów zamówienia. Konfiguracja: [opis dashboardu](../metabase/domain/product_details/dashboard.md).

**Dane w widoku zamówienia:** 547 zamówień ma kilka opinii, a 789 opinii (`review_id`) jest przypisanych do kilku zamówień, więc `review_id` nie jest kluczem. W 369 zamówieniach suma płatności różni się od wartości produktów z transportem. 775 zamówień nie ma pozycji, a jedno (`bfbd0f9b…`) nie ma płatności. 2 płatności kartą mają 0 rat, a 3 płatności `not_defined` mają kwotę 0.

**Dane w widoku produktu:** każdy z 32 951 produktów ma co najmniej jedną sprzedaż. Najczęściej sprzedawany produkt ma 527 sztuk w 431 zamówieniach, więc lista zamówień produktu mieści się w limicie 2000 wierszy; przy większych zbiorach trzeba będzie ją stronicować. Ten sam produkt może mieć różne ceny u różnych sprzedawców – np. `d285360f…` kosztuje od 154,91 do 349,99, a najwięcej sztuk sprzedaje najtańszy sprzedawca. Statystyki w podsumowaniu liczą osobne podzapytania, z których każde przegląda `order_items`; przy dużych zbiorach warto zebrać je w jedno przejście.

**Klienci w Olist:** `customer_id` jest kluczem klienta w kontekście jednego zamówienia (zawsze dokładnie 1 zamówienie), osobę identyfikuje `customer_unique_id` – 96 096 osób na 99 441 rekordów, 2 997 osób kupiło więcej niż raz (maks. 17 zamówień). Przeglądarka pokazuje rekordy tabeli i liczbę unikalnych osób.

**Filtr miasta (przeglądarka klientów):** pole `customers.customer_city` ma w metadanych typ City, a mimo to filtr typu Location nie widzi zmiennej `miasto` (Field Filter w pytaniu SQL). Filtr stanu (`customer_state`, typ State) podłączył się bez problemu. Dla miasta używam filtra **Text or Category → Is**, który działa z tą samą zmienną.

**Kategorie produktów:** 610 produktów nie ma kategorii, 13 ma kategorię bez tłumaczenia (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`). Kolumna `Kategoria` pokazuje nazwę angielską, a gdy jej brak – portugalską albo „(brak kategorii)”. W przeglądarce z paginacją serwerową filtr Kategoria korzysta z oryginalnej nazwy portugalskiej (`product_category_name`), a przy sortowaniu po kategorii produkty „(brak kategorii)” trafiają na koniec listy.

### 8.3. Przegląd danych – wersja tylko do odczytu

**PDF:** [PDF](dashboards/data_overview_v1.pdf) · **Pytania i opis dashboardu:** `metabase/universal/data_overview/`

Dashboard działa dla każdej bazy w ClickHouse bez zapisu czegokolwiek w bazie – wystarczy konto z uprawnieniem SELECT:
- tabele, liczba rekordów, kolumny i rozmiar – z tabel systemowych ClickHouse (`system.tables`, `system.columns`), bez skanowania danych,
- profil kolumn wybranej tabeli (braki, wartości unikalne, zakresy dat) – jedno uniwersalne zapytanie liczone na bieżąco: tabela wskazana parametrem (`merge()`), każdy wiersz zamieniany na pary kolumna–wartość (`formatRowNoNewline('JSONEachRow', *)` + `JSONExtractKeysAndValuesRaw`), więc zapytanie nie zna nazw kolumn.

**Czas profilu (Olist):** orders 0,7 s, reviews 0,4 s, geolocation (1 mln wierszy) 1,0 s – koszt rośnie z liczbą wierszy × kolumn; przy setkach milionów wierszy profil trzeba będzie liczyć wcześniej i zapisywać.

**Filtry z listą wartości z pytań SQL:** lista baz pochodzi z pytania `u00` (sama obejmie nowe bazy, do których konto ma uprawnienia), lista tabel z `u01`.

**Problemy z jakością danych Olist wykryte przez profil:**
- `geolocation`: współrzędne poza Brazylią (szerokość do 45°, długość do 121°) i wartość `* cidade` w nazwach miast,
- `order_items.shipping_limit_date` sięga 2020-04-09, choć dane kończą się w 2018 r.,
- `reviews.review_id` nie jest unikalne (98 410 wartości na 99 224 wiersze), `review_comment_title` puste w 88% wierszy,
- 2 965 zamówień (3%) bez daty dostarczenia, 610 produktów (1,85%) bez kategorii.

### 8.4. Rozkłady wartości kolumny

**PDF:** [kolumna tekstowa](dashboards/data_overview_v2_order_status.pdf) · [kolumna liczbowa](dashboards/data_overview_v2_product_weight_g.pdf) · [kolumna z brakami](dashboards/data_overview_v2_review_comment_title.pdf) · **Pytania:** `u08`–`u14` w `metabase/universal/data_overview/`

Dla tabeli i kolumny wybranych filtrem (kliknięcie kolumny w profilu tabeli): podsumowanie kolumny, rozkład wartości (top 10 + pozostałe + braki), histogram i statystyki (kolumny liczbowe), rozkład w czasie (daty), wartości powtarzające się i najrzadsze. Zapytania są uniwersalne – wartość kolumny wyciągają z wiersza zamienionego na JSON (`JSONExtractRaw(formatRowNoNewline('JSONEachRow', *), kolumna)`), a typ kolumny sprawdzają w `system.columns`. Karty niepasujące do typu kolumny zwracają pusty wynik i są ukrywane.

**Wydajność:** warunek typu kolumny w najbardziej wewnętrznym zapytaniu sprawia, że dla kolumny niepasującego typu ClickHouse w ogóle nie czyta tabeli (1,1 s → 0,006 s). Rozkład kolumny w tabeli z 1 mln wierszy liczy się w 0,3–0,5 s. Histogram obejmuje zakres od 1. do 99. percentyla, a wartości skrajne trafiają do skrajnych przedziałów.

**Problemy z jakością danych:**
- `reviews.review_id`: 789 zduplikowanych identyfikatorów, 814 nadmiarowych wierszy,
- niespójny zapis tych samych wartości: `sao paulo` / `são paulo` w `geolocation`, „Recomendo” / „recomendo” i „Ótimo” / „Otimo” w tytułach recenzji,
- kategorie produktów z pojedynczymi produktami (`cds_dvds_musicais` – 1, `seguros_e_servicos` – 2),
- wagi produktów z długim ogonem (mediana 700 g, 95. percentyl 10 850 g, maksimum 40 425 g).

### 8.5. Stan prac względem zakresu etapu 2

| Widok | Stan | Sekcja |
|---|---|---|
| Przegląd danych (tabele, rekordy, kolumny, zakresy dat, braki) | gotowe – widok uniwersalny, tylko do odczytu | 8.3 |
| Lista rekordów (wyszukiwarka, filtry, paginacja) | gotowe – przeglądarki Zamówień, Klientów i Produktów, paginacja po stronie ClickHouse (31–36) | 8.1, 8.2 |
| Widok szczegółowy rekordu | częściowo – dashboardy szczegółów zamówienia (37–42) i produktu (43–47); klient do zrobienia | 8.2 |
| Nawigacja po powiązaniach | częściowo – lista zamówień -> szczegóły zamówienia <-> szczegóły produktu; przeglądarka produktów -> szczegóły produktu; powrót do list z zachowanymi filtrami | 8.2 |
| Analiza jakości danych | gotowe – braki, wartości unikalne, zakresy, rozkłady, duplikaty, wartości rzadkie | 8.3, 8.4 |
| Podstawowe wskaźniki | gotowe – kafelki w przeglądzie danych | 8.3 |
| Obsługa dużych zbiorów (pomiary czasu, optymalizacje) | do zrobienia | – |