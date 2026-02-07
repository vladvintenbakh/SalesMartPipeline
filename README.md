# Sales Mart Pipeline

Airflow DAG `sales_mart` that pulls daily order increments from an HTTP API, stages them in Postgres, and updates a simple star schema:
- **Dimensions:** `d_item`, `d_customer`, `d_city`, `d_calendar`
- **Facts:** `f_sales`, `f_customer_retention`.

## Quick Setup

**Airflow connections**
- Postgres: `postgresql_de`
- HTTP API: `http_conn_id` (put `{"api_key":"<KEY>"}` in *Extras*). Edit `nickname`, `cohort`, and `postgres_conn_id` in `src/dags/dag.py`.

**DB**
```sql
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;
```
Ensure `mart.d_calendar(date_id, date_actual, week_of_year, ...)` exists.

**Python dependencies**: `apache-airflow>=2`, `apache-airflow-providers-postgres`, `psycopg2-binary`, `pandas`, `requests`.

## Notes

- `f_sales`: negates `payment_amount` when `status='refunded'`.
- `f_customer_retention`: weekly per `item_id` (new/returning/refunded customer counts and revenues).
- Staging expects: `uniq_id`, `date_time`, `item_*`, `customer_*`, `city_*`, `quantity`, `payment_amount`, `status`.

## Troubleshooting
- 401/403 → check HTTP extras/headers.
- Missing tables → run migrations & ensure `d_calendar` is filled correctly.
- Permission issues → Postgres credentials & worker file access.
