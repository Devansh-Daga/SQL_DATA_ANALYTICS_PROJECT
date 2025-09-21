/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
select 
	min (order_Date) as first_order_date,
	max(order_date) as last_ordr_date,
	extract (year from max(order_date))- extract(year from min (order_Date)) as order_range_years
from gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
select 
	min(birthdate) as oldest_birthdate,
	extract(year from age(current_date,min(birthdate))) as oldest_age,
	max(birthdate) as youngest_birthdate,
	extract(year from age(current_date,max(birthdate))) as youngest_age
from gold.dim_customers;
