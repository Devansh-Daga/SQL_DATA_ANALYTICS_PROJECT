/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*
segment products into cost ranges and
count how many products fall into each segment 
*/
with product_segment as (
	select 
		product_key,
		product_name,
		cost,
		case
			when cost <100 then 'Below 100'
			when cost between 100 and 500 then '100-500'
			when cost between 500 and 1000 then '500-1000'
			else 'Above 1000'
		end as cost_range
	from gold.dim_products
)
select 
	cost_range ,
	count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc


-- group customers into three segments based on their spending behaviour 
	-- vip : alteast 12 month of history and spending > 5000
	-- regular : alteast 12 month of history and spending <= 5000
	-- new : lifespan less than 12 months 
-- total number customer by each group

with customer_spending as (
	select 
		c.customer_key,
		sum(f.sales_amount) as total_spending,
		min(order_date) as first_order,
		max(order_date) as last_order,
		EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 
          + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS life_span
	from gold.fact_sales as f
	left join gold.dim_customers as c
	on f.customer_key = c.customer_key
	group by c.customer_key
)
SELECT 
	CUSTOMER_SEGMENT,
	COUNT(CUSTOMER_KEY) AS TOTAL_CUSTOMER
FROM (
	SELECT 
		CUSTOMER_KEY,
		CASE 
			WHEN LIFE_SPAN >= 12 AND TOTAL_SPENDING > 5000 THEN 'VIP'
			WHEN LIFE_SPAN >= 12 AND TOTAL_SPENDING <= 5000 THEN 'REGULAR'
			ELSE 'NEW'
		END AS CUSTOMER_SEGMENT
	FROM CUSTOMER_SPENDING
) GROUP BY CUSTOMER_SEGMENT
ORDER BY TOTAL_CUSTOMER DESC
