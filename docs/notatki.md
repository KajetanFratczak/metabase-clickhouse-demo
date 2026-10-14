# Metabase + ClickHouse — pierwszy kontakt

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

Pojawił się błąd `Invalid LZ4 magic byte: '-112'`. W **Additional JDBC connection string options / Dodatkowe opcje połączenia JDBC** trzeba było ustawić:

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