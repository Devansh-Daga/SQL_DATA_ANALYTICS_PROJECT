/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- which 5 products generate the highest revenue 
--simple ranking 
select 
	p.product_name,
	sum(f.sales_amount) as total_revenue
from gold.fact_sales as f
left join gold.dim_products as p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc
limit 5;

-- with use of window function
select *
from (
	select 
		p.product_name,
		sum(f.sales_amount) as total_revenue,
		row_number() over(order by sum(f.sales_amount) desc) as rank_products
	from gold.fact_sales as f
	left join gold.dim_products as p
	on p.product_key = f.product_key
	group by p.product_name
) where rank_products <= 5 

-- what are the 5 worst performing products in terms of sales
select 
	p.product_name,
	sum(f.sales_amount) as total_revenue
from gold.fact_sales as f
left join gold.dim_products as p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue 
limit 5;

-- Find the top 10 customers who have generated the highest revenue
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- The 3 customers with the fewest orders placed
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders 
LIMIT 3;
