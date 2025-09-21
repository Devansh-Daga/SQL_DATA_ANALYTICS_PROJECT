/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: EXTRACT(),TO_CAHR()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions

SELECT
	EXTRACT(YEAR FROM ORDER_DATE) AS ORDER_YEAR,
	EXTRACT(MONTH FROM ORDER_DATE) AS ORDER_MONTH,
	sum(SALES_AMOUNT) as total_sales,
	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM GOLD.FACT_SALES
where order_date is not null
group by EXTRACT(YEAR FROM ORDER_DATE), EXTRACT(MONTH FROM ORDER_DATE)
ORDER BY  EXTRACT(YEAR FROM ORDER_DATE),EXTRACT(MONTH FROM ORDER_DATE)

-- FORMATTING THE DATE COLUMN
SELECT
  	TO_CHAR(ORDER_DATE,'YYYY-MM') AS ORDER_YEAR,
  	sum(SALES_AMOUNT) as total_sales,
  	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
  	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM GOLD.FACT_SALES
where order_date is not null
group by TO_CHAR(ORDER_DATE,'YYYY-MM')
ORDER BY  TO_CHAR(ORDER_DATE,'YYYY-MM')
