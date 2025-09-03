alter table staging.user_order_log
add column status text default 'shipped';

alter table mart.f_sales
add column status text default 'shipped';