insert into mart.f_customer_retention (
    new_customers_count,
    returning_customers_count,
    refunded_customers_count,
    period_name,
    period_id,
    item_id,
    new_customers_revenue,
    returning_customers_revenue,
    customers_refunded
)
with customers as (
	select 
		fs.date_id, 
		week_of_year,
		item_id, 
		customer_id, 
		quantity, 
		payment_amount,
		status
	from mart.f_sales fs
	join mart.d_calendar dc
	using(date_id)
	where week_of_year = date_part('week', '2025-09-02'::DATE) -- replace with Airflow current date
),
new_customers as (
	select customer_id
	from customers
	where status = 'shipped'
	group by customer_id 
	having count(*) = 1
),
returning_customers as (
	select customer_id
	from customers
	where status = 'shipped'
	group by customer_id 
	having count(*) > 1
),
refunded_customers as (
	select customer_id
	from customers
	where status = 'refunded'
	group by customer_id 
),
customer_count_by_category as (
	select
		week_of_year as period_id,
		item_id, 
		count(distinct customer_id) filter (where customer_id in (select * from new_customers)) as new_customers_count,
		count(distinct customer_id) filter (where customer_id in (select * from returning_customers)) as returning_customers_count,
		count(distinct customer_id) filter (where customer_id in (select * from refunded_customers)) as refunded_customers_count
	from customers
	group by item_id, week_of_year
),
revenue_by_category as (
	select
		week_of_year as period_id,
		item_id,
		coalesce(sum(quantity * payment_amount) filter (where customer_id in (select * from new_customers)), 0) as new_customers_revenue,
		coalesce(sum(quantity * payment_amount) filter (where customer_id in (select * from returning_customers)), 0) as returning_customers_revenue,
		count(*) filter (where customer_id in (select * from refunded_customers)) as customers_refunded
	from customers
	group by item_id, week_of_year
)
select
	new_customers_count,
	returning_customers_count,
	refunded_customers_count,
	'weekly' as period_name,
	cc.period_id as period_id,
	cc.item_id as item_id,
	new_customers_revenue,
	returning_customers_revenue,
	customers_refunded
from customer_count_by_category cc
join revenue_by_category r
on cc.period_id = r.period_id and cc.item_id = r.item_id;