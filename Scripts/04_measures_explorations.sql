/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- find the total sales
select 
	sum(sales_amount) as total_sales
from gold.fact_sales;

-- find the how many items are sold 
select 
	sum(quantity) as total_quantity
from gold.fact_sales;

-- find the average selling price 
select 
	avg(price ) as avg_price 
from gold.fact_sales;

-- find total number of order
select count(order_number) as total_number_of_orders
from gold.fact_sales;
-- not including duplicates
select count(distinct order_number) as total_number_of_orders
from gold.fact_sales

-- find the total number of products
select count(product_key) as total_products 
from gold.dim_products

--find the total number of customers
select 
	count(customer_key) as total_customers 
from gold.dim_customers

-- find the total number of customers that have placed an order 
select 
	count(distinct customer_key) 
from gold.fact_sales

-- generating a report that shows all key metric for the business
select 'Total Sales' as measure_name,sum(sales_amount) as measure_value
from gold.fact_sales
UNION ALL
select 'Total Quantity', sum(quantity) 
from gold.fact_sales 
UNION ALL
select 'Average Price', avg(price ) 
from gold.fact_sales
UNION ALL
select 'Total Number of Orders', count(distinct order_number)
from gold.fact_sales
UNION ALL
select 'Total Number of Products', count(distinct product_key)
from gold.dim_products
UNION ALL
select 'Total Number of Customers', count(customer_key) 
from gold.dim_customers
