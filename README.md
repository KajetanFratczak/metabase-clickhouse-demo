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
├─ docker-compose.yml          usługi: ClickHouse, Metabase, PostgreSQL
├─ .env.example                wzór pliku z hasłami (.env nie ma w repozytorium)
├─ sql/                        tworzenie tabel i import danych do ClickHouse
├─ metabase/                   pytania (SQL) i opisy dashboardów Metabase
│  ├─ domain/                  widoki na danych Olist
│  │  ├─ sales_performance/    dashboard Sales Performance (pytania 00–24)
│  │  └─ browsers/             przeglądarki rekordów (pytania 25–30)
│  └─ universal/               widoki działające dla dowolnej bazy
│     └─ data_overview/        przegląd danych (u00–u06)
└─ docs/
   ├─ notatki.md               ustalenia: standard / Pro / obejścia
   ├─ dashboards/              wydruki dashboardów (PDF)
   └─ screenshots/             zrzuty pytań, w podfolderach jak w metabase/
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

### 8. Pytania i dashboardy

Darmowa wersja Metabase nie eksportuje pytań ani dashboardów do plików (funkcja *serialization* jest w wersjach Pro i Enterprise). Repozytorium zawiera więc SQL każdego pytania i opisy dashboardów – zasady odtwarzania są w [metabase/README.md](metabase/README.md), a wydruki dashboardów w `docs/dashboards/`.

### 9. Przegląd danych (widok uniwersalny)

Nie wymaga żadnych zmian w ClickHouse – wystarczy konto `demo_reader` z uprawnieniem SELECT. Pytania SQL z `metabase/universal/data_overview/` dodaj w Metabase (+ New → SQL query, zmienne według nagłówka pliku), a dashboard złóż według [opisu dashboardu](metabase/universal/data_overview/dashboard.md).

### Zatrzymanie

- `docker compose down` – zatrzymuje usługi, dane zostają.
- `docker compose down -v` – usuwa także wolumen ClickHouse (trzeba ponownie zaimportować dane); konfiguracja Metabase w `pg_data/` zostaje.

## Stan prac

**Etap 1 (14–15.10.2026):** środowisko, import danych Olist, dashboard Sales Performance ([PDF](docs/dashboards/sales_performance_v2.pdf)).

**Etap 2 (od 27.10.2026) – uniwersalne widoki:**
- przeglądarki rekordów Zamówień, Klientów i Produktów – wyszukiwarka, filtry po stronie serwera, liczba wyników, wersje z paginacją ([PDF](docs/dashboards/browser_orders.pdf)),
- przegląd danych dla dowolnej bazy ClickHouse – tabele, rekordy, kolumny, zakresy dat, braki danych, tylko do odczytu ([PDF](docs/dashboards/data_overview.pdf)).

**Dalsze prace:** rozkłady wartości (analiza jakości danych), widok szczegółowy rekordu z nawigacją po powiązaniach, pulpit główny łączący widoki, testy na dużych zbiorach danych (pomiar czasu zapytań, optymalizacje).

Szczegóły i ustalenia: [docs/notatki.md](docs/notatki.md).

## Autor

Kajetan Frątczak, październik 2026