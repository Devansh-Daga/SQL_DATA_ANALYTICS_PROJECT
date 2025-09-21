/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- CALCULATES THE TOTAL SALES PER MONTH AND RUNNING TOTAL OF SALES OVER TIME
SELECT 
	CAST(ORDER_DATE AS date),
	TOTAL_SALES,
	SUM(TOTAL_SALES) OVER(PARTITION BY ORDER_DATE ORDER BY ORDER_DATE) AS RUNNING_TOTAL_SALES,
	AVG(AVG_PRICE) OVER(ORDER BY ORDER_DATE) AS RUNNING_AVG_PRICE
FROM (
SELECT 
	DATE_TRUNC('year' ,ORDER_DATE) AS ORDER_DATE,
	SUM(SALES_AMOUNT) AS TOTAL_SALES,
	AVG(PRICE) AS AVG_PRICE
FROM GOLD.FACT_SALES
WHERE ORDER_DATE IS NOT NULL
GROUP BY DATE_TRUNC('year' ,ORDER_DATE));
