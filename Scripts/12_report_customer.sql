/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
DROP IF EXISTS GOLD.REPORT_CUSTOMERS 
CREATE VIEW GOLD.REPORT_CUSTOMERS AS (
	WITH BASE_QUERY AS(
	/*---------------------------------------------------------------------------
	1) Base Query: Retrieves core columns from fact_sales and dim_customers
	---------------------------------------------------------------------------*/ 
		SELECT 
			F.ORDER_NUMBER,
			F.PRODUCT_KEY,
			F.ORDER_DATE,
			F.SALES_AMOUNT,
			F.QUANTITY,
			C.CUSTOMER_KEY,
			C.CUSTOMER_NUMBER,
			CONCAT(C.FIRST_NAME,' ',C.LAST_NAME) AS CUSTOMER_NAME,
			EXTRACT(YEAR FROM AGE(CURRENT_DATE,C.BIRTHDATE)) AS AGE
		FROM GOLD.FACT_SALES AS F
		LEFT JOIN GOLD.DIM_CUSTOMERS AS C 
		ON C.CUSTOMER_KEY = F.CUSTOMER_KEY
		WHERE ORDER_DATE IS NOT NULL
	)
	, CUSTOMER_AGGREGATION AS (
	/*---------------------------------------------------------------------------
	2) Customer Aggregations: Summarizes key metrics at the csutomer level
	---------------------------------------------------------------------------*/
		SELECT 
			CUSTOMER_KEY,
			CUSTOMER_NUMBER,
			CUSTOMER_NAME,
			AGE,
			COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,
			SUM(SALES_AMOUNT) AS TOTAL_SALES,
			SUM(QUANTITY) AS TOTAL_QUANTITY,
			COUNT(DISTINCT PRODUCT_KEY) AS TOTAL_PRODUCTS,
			MAX(ORDER_DATE) AS LAST_ORDER_DATE,
			EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 
		          + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS life_span
			
		FROM BASE_QUERY
		GROUP BY 
			CUSTOMER_KEY,
			CUSTOMER_NUMBER,
			CUSTOMER_NAME,
			AGE
	)
	/*---------------------------------------------------------------------------
  3) Final Query: Combines all results related to customer into one output
---------------------------------------------------------------------------*/
	SELECT 
		CUSTOMER_KEY,
		CUSTOMER_NUMBER,
		CUSTOMER_NAME,
		AGE,
		CASE 
			WHEN AGE < 20 THEN 'UNDER 20'
			WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
			WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
			WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50 AND ABOVE'
		END AS AGE_GROUP,
		CASE 
				WHEN LIFE_SPAN >= 12 AND TOTAL_SALES > 5000 THEN 'VIP'
				WHEN LIFE_SPAN >= 12 AND TOTAL_SALES <= 5000 THEN 'REGULAR'
				ELSE 'NEW'
			END AS CUSTOMER_SEGMENT,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE, LAST_ORDER_DATE)) * 12 
		          + EXTRACT(MONTH FROM AGE(CURRENT_DATE,LAST_ORDER_DATE)) AS RECENCY,
		TOTAL_ORDERS,
		TOTAL_SALES,
		TOTAL_QUANTITY,
		TOTAL_PRODUCTS,
		LIFE_SPAN,
		-- COMPUTE AVERAGE ORDER VALUE (AVD)
		CASE WHEN TOTAL_SALES = 0 THEN 0
			ELSE TOTAL_SALES/TOTAL_ORDERS
		END AS AVERAGE_ORDER_VALUE,
		-- COMPUTE AVERAGE ORDER VALUE (AVD)
		CASE WHEN LIFE_SPAN = 0 THEN TOTAL_SALES
			ELSE TOTAL_SALES/LIFE_SPAN
		END AS AVERAGE_MONTHLY_SPEND
	FROM CUSTOMER_AGGREGATION	
)	
