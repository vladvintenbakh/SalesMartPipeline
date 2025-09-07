# Sales Mart Pipeline — Airflow + Postgres

Airflow DAG `sales_mart` that pulls daily order increments from an HTTP API, stages them in Postgres, and updates a simple star schema:
**dims:** `d_item`, `d_customer`, `d_city`, `d_calendar` • **facts:** `f_sales`, `f_customer_retention`.

---

## Project Layout
```
de-project-sprint-3-main/
├─ migrations/
│  ├─ 01_DDL_add_status_column.sql
│  └─ 02_DDL_create_customer_retention.sql
└─ src/dags/
   ├─ dag.py
   └─ sql/
      ├─ mart.d_city.sql
      ├─ mart.d_customer.sql
      ├─ mart.d_item.sql
      ├─ mart.f_sales.sql
      └─ mart.f_customer_retention.sql
```

## Quick Setup

**Airflow connections**
- Postgres: `postgresql_de`
- HTTP API: `http_conn_id` (put `{"api_key":"<KEY>"}` in *Extras*).  
  Edit `nickname`, `cohort`, and `postgres_conn_id` in `src/dags/dag.py`.

**DB**
```sql
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;
```
Ensure `mart.d_calendar(date_id, date_actual, week_of_year, ...)` exists.

**Python deps**
`apache-airflow>=2`, `apache-airflow-providers-postgres`, `psycopg2-binary`, `pandas`, `requests`.

## Run

Place files so Airflow sees:
```
$AIRFLOW_HOME/dags/dag.py
$AIRFLOW_HOME/dags/sql/*.sql
```
Start & unpause:
```bash
airflow db init
airflow webserver
airflow scheduler
```

Backfill example:
```bash
airflow dags backfill -s 2025-09-01 -e 2025-09-06 sales_mart
```

## Notes

- `f_sales`: negates `payment_amount` when `status='refunded'`.
- `f_customer_retention`: weekly per `item_id` (new/returning/refunded and revenues).
- Staging expects: `uniq_id`, `date_time`, `item_*`, `customer_*`, `city_*`, `quantity`, `payment_amount`, `status`.

## Migrations
```sql
\i migrations/01_DDL_add_status_column.sql
\i migrations/02_DDL_create_customer_retention.sql
```

## Troubleshooting
- 401/403 → check HTTP extras/headers.
- Missing tables → run migrations & ensure `d_calendar`.
- Permission issues → Postgres creds & worker file access.

## License
MIT (or your org’s license)
