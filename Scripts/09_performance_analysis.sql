/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

-- - ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY COMPARING EACH PRODUCT'S SALES 
-- TO BOTH AVERAGE SALES PERFORMANCE AND THE PREVIOUS YEAR'S SALES
WITH YEARLY_PRODUCT_SALES AS (
	select 
		extract(year from f.order_date) as order_year,
		p.product_name,
		sum(f.sales_amount) as current_sales
	from gold.fact_sales as f
	left join gold.dim_products as p
	on f.product_key = p.product_key
	where order_date is not null
	group by extract(year from f.order_date),p.product_name 
)
SELECT
	ORDER_YEAR,
	PRODUCT_NAME,
	CURRENT_SALES,
	AVG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME) AVG_SALES,
	CASE 
		WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME) > 0 THEN 'ABOVE AVERAGE'
		WHEN CURRENT_SALES - AVG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME) < 0 THEN 'BELOW AVERAGE'
		ELSE 'AVERAGE'
	END AS AVG_CHANGE,
  --year-over-year analysis
	LAG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) AS PREVIOUS_YEAR_SALES,
	CURRENT_SALES - LAG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR)  AS DIFF_PY,
	CASE 
		WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) > 0 THEN 'INCREASE'
		WHEN CURRENT_SALES - LAG(CURRENT_SALES) OVER(PARTITION BY PRODUCT_NAME ORDER BY ORDER_YEAR) < 0 THEN 'DECREASE'
		ELSE 'NO CHANGE'
	END AS PY_CAHNGE
FROM YEARLY_PRODUCT_SALES
ORDER BY PRODUCT_NAME,ORDER_YEAR
