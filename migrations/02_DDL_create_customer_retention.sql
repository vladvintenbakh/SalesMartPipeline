drop table if exists mart.f_customer_retention;

create table mart.f_customer_retention (
    new_customers_count int,
    returning_customers_count int,
    refunded_customers_count int,
    period_name text default 'weekly',
    period_id bpchar(10),
    item_id int references mart.d_item(item_id),
    new_customers_revenue numeric(15, 2),
    returning_customers_revenue numeric(15, 2),
    customers_refunded int
);