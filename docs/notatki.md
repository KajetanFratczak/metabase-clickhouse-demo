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

## 4. Wizualizacja danych — tworzenie dashboardów

Przechodzę do **Studia Danych**, gdzie mogę edytować metadane.

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

Aby dodać filtry, zrobiłem joiny w pytaniach 00 01, 02, 03, 10, 11 (Join Customers). 05, 06, 22, 23, 24 (Join Orders + Join Customers). 

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
| Zamówienia | 25, 26; z paginacją 31, 32 | Szukaj, data zakupu, status, stan klienta, ID klienta | [PDF](dashboards/browser_orders.pdf), [z paginacją](dashboards/browser_orders_paged.pdf) |
| Klienci | 27, 28, 28b; z paginacją 33, 34 | Szukaj, stan, miasto | [PDF](dashboards/browser_customers.pdf), [z paginacją](dashboards/browser_customers_paged.pdf) |
| Produkty | 29, 30; z paginacją 35, 36 | Szukaj, kategoria, waga | [PDF](dashboards/browser_products.pdf), [z paginacją](dashboards/browser_products_paged.pdf) |

**Co ustaliłem podczas pracy:**
- Lista i licznik powinny reagować na te same filtry. Najłatwiej zacząć od duplikatu pytania listy i zmienić podsumowanie na liczbę wierszy.
- Licznik nie musi wyświetlać tych samych kolumn co lista. Ważne, żeby obejmował ten sam zbiór rekordów.
- Przy połączeniach sprawdzam, czy jeden rekord nie pojawia się kilka razy.
- Brakujące wartości z połączonych tabel obsługuję przed połączeniem tekstu, np. przez `coalesce`. W przeciwnym razie całe `concat` może zwrócić `NULL`.
- Kolumnę `Szukaj` zostawiam do filtrowania, ale ukrywam ją w widocznej tabeli.
- Dla filtrów z listą rozwijaną korzystam przede wszystkim z kolumn źródłowych.
- Ustawiam jednoznaczne sortowanie. Jeżeli pierwsza kolumna może się powtarzać, dodaję identyfikator rekordu jako drugie sortowanie.

### 8.2. Ustalenia

**Paginacja:** Metabase nie pobiera kolejnych stron z bazy. Filtry, sortowanie i wyszukiwanie wykonuje ClickHouse, ale do przeglądarki trafia najwyżej 2 000 wierszy (zmienna `MB_UNAGGREGATED_QUERY_ROW_LIMIT`), które karta dzieli na strony po stronie przeglądarki. Dlatego każda przeglądarka pokazuje liczbę wszystkich pasujących rekordów. Prawdziwa paginacja serwerowa wymagałaby pytania SQL z `LIMIT`/`OFFSET`.

**Widok rekordu i powiązania:** kliknięcie identyfikatora otwiera wbudowaną kartę rekordu Metabase ze wszystkimi polami i powiązanymi rekordami (na podstawie kluczy ustawionych w metadanych).

**Klienci w Olist:** `customer_id` jest kluczem klienta w kontekście jednego zamówienia (zawsze dokładnie 1 zamówienie), osobę identyfikuje `customer_unique_id` – 96 096 osób na 99 441 rekordów, 2 997 osób kupiło więcej niż raz (maks. 17 zamówień). Przeglądarka pokazuje rekordy tabeli i liczbę unikalnych osób.

**Kategorie produktów:** 610 produktów nie ma kategorii, 13 ma kategorię bez tłumaczenia (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`). Kolumna `Kategoria` pokazuje nazwę angielską, a gdy jej brak – portugalską albo „(brak kategorii)”.