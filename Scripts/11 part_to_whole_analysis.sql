/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/


-- PART TO WHOLE ANALYSIS 
-- WHICH CATEGORIES CONTRIBUTES THE MOST TO OVERALL SALES 
WITH CATEGORY_SALES AS(
	SELECT 
		P.CATEGORY,
		SUM(SALES_AMOUNT) AS TOTAL_SALES
	FROM GOLD.FACT_SALES AS F
	LEFT JOIN GOLD.DIM_PRODUCTS AS P
	ON P.PRODUCT_KEY = F.PRODUCT_KEY
	GROUP BY CATEGORY
)
SELECT 
	CATEGORY,
	TOTAL_SALES,
	SUM(TOTAL_SALES) OVER() AS OVERALL_SALES,
	CONCAT(ROUND((TOTAL_SALES / SUM(TOTAL_SALES) OVER()) * 100,2),'%') AS PERCENTAGE_OF_TOTAL
FROM CATEGORY_SALES
ORDER BY TOTAL_SALES DESC
