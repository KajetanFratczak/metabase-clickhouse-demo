# Prototyp pulpitu głównego – Metabase + ClickHouse (Brazilian E-Commerce Olist dataset)

Prototyp układu pulpitu głównego (strony startowej) w **Metabase** dla danych przechowywanych w **ClickHouse**.\
Celem projektu jest sprawdzenie, jak w Metabase organizować karty, wykresy, sekcje i filtry, aby strona główna ułatwiała poruszanie się po dostępnych widokach i danych.

Prace prowadzone są na publicznych danych testowych brazylijskiego e-commerce Olist.

## Technologie

- ClickHouse - przechowywanie danych 
- Metabase - zapytania, wizualizacje, dashboardy
- PostgreSQL - konfiguracja, konta i zapisane obiekty Metabase
- Docker Compose - uruchomienie środowiska lokalnego

## Architektura

| Usługa | Obraz | Port | Rola |
|---|---|---|---|
| ClickHouse | `clickhouse/clickhouse-server:26.9.18.11` | 127.0.0.1:8123 | magazyn danych |
| Metabase | `metabase/metabase:v0.64.2.2` | 127.0.0.1:3000 | wizualizacja, dashboardy |
| PostgreSQL | `postgres:16` | – | baza aplikacyjna Metabase |

## Dane testowe

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)\
Ok. 100 tys. zamówień z brazylijskiego marketplace'u (wrzesień 2016 – październik 2018).\
Zbiór ma kilka powiązanych tabel i pokrywa typowe obszary analiz: sprzedaż, logistykę, płatności i satysfakcję klientów.

| Tabela (`olist_raw`) | Plik CSV | Wiersze |
|---|---|---|
| `orders` | olist_orders_dataset.csv | 99 441 |
| `order_items` | olist_order_items_dataset.csv | 112 650 |
| `payments` | olist_order_payments_dataset.csv | 103 886 |
| `reviews` | olist_order_reviews_dataset.csv | 99 224 |
| `customers` | olist_customers_dataset.csv | 99 441 |
| `products` | olist_products_dataset.csv | 32 951 |
| `sellers` | olist_sellers_dataset.csv | 3 095 |
| `category_name_translation` | product_category_name_translation.csv | 71 |
| `geolocation` | olist_geolocation_dataset.csv | 1 000 163 |

## Struktura repozytorium
```
├─ docker-compose.yml       usługi: ClickHouse, Metabase, PostgreSQL
├─ .env.example             wzór pliku z hasłami (.env nie ma w repozytorium)
├─ sql/                     tworzenie tabel i import danych do ClickHouse
├─ metabase/questions/      SQL pytań z Metabase
└─ docs/
   ├─ notatki.md            ustalenia: standard / Pro / obejścia
   └─ screenshots/          zrzuty pytań i dashboardów
```

## Uruchomienie
**Wymagania:** Wymagany jest działający Docker Desktop z obsługą kontenerów Linux.

### 1. Konfiguracja

```powershell
git clone https://github.com/KajetanFratczak/metabase-clickhouse-demo.git
cd metabase-clickhouse-demo
Copy-Item .env.example .env
```

Uzupełnij hasła w `.env`.

### 2. Dane

Pobierz zbiór z Kaggle (wymaga konta) i rozpakuj 9 plików CSV bezpośrednio do `data/olist/`.

### 3. Start

```powershell
docker compose up -d
docker compose ps
```

Wszystkie trzy usługi powinny mieć status `healthy`. Pierwszy start Metabase trwa ok. 1–2 min.

### 4. Import danych do ClickHouse

> **Uwaga:** skrypty `*_import.sql` wykonują `TRUNCATE TABLE`,
> a następnie ponownie importują CSV. Każde uruchomienie usuwa
> dotychczasową zawartość wskazanej tabeli.
> Jeśli import zakończy się błędem, tabela może pozostać pusta
> lub częściowo załadowana. Skrypty są przeznaczone do pełnego
> przeładowania lokalnych danych testowych.

Wykonaj skrypty z sql/ jako użytkownik administracyjny ClickHouse. Zacznij od create_database.sql, który tworzy bazę olist_raw.

### 5. Weryfikacja

W konsoli ClickHouse (`http://localhost:8123/play`, użytkownik z `.env`):

```sql
SELECT name, total_rows FROM system.tables WHERE database = 'olist_raw' ORDER BY name;
```

Liczby wierszy muszą się zgadzać z tabelą w sekcji „Dane testowe”.

### 6. Konto tylko do odczytu dla Metabase

```powershell
docker compose exec clickhouse clickhouse-client --user demo_admin --password
```

```sql
CREATE USER IF NOT EXISTS demo_reader IDENTIFIED WITH sha256_password BY '<hasło>';
GRANT SELECT ON olist_raw.* TO demo_reader;
```

Metabase łączy się tym kontem, więc z poziomu Metabase (również z edytora SQL) nie da się zmienić ani usunąć danych.

### 7. Konfiguracja Metabase

`http://localhost:3000` -> kreator -> konto administratora.
Następnie **Admin settings -> Databases -> Add database -> ClickHouse**:

| Pole | Wartość |
|---|---|
| Host | `clickhouse` – nazwa usługi w sieci Compose (nie `localhost`) |
| Port | `8123` |
| Username / Password | `demo_reader` / hasło z kroku 6 |
| Databases | `olist_raw` lub zostawiamy wszystkie domyślnie |
| Additional JDBC connection string options | `compress=false` |


## Aktualny zakres i dalsze prace

- Przygotowane środowisko i skrypty importu dziewięciu tabel.
- Konfiguracja metadanych, relacji i pierwszych wizualizacji w Metabase.
- Dalsze prace: rozwój dashboardów, porównanie wariantów pulpitu oraz dokumentacja wskaźników i filtrów.

Pytania, metadane i dashboardy są zapisywane w bazie aplikacyjnej Metabase. Skrypty importu odtwarzają tabele źródłowe; opisy wizualizacji i zrzuty ekranu będą dodawane do repozytorium w toku prac.

## Notatki z pracy

[Przebieg konfiguracji i ustalenia](docs/notatki.md)

## Autor

Kajetan Frątczak, październik 2026