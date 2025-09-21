/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
CREATE VIEW GOLD.REPORT_PRODUCTS AS (


WITH BASE_QUERY AS(
		/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
		SELECT 
			F.CUSTOMER_KEY,
			F.ORDER_NUMBER,
			F.ORDER_DATE,
			F.SALES_AMOUNT,
			F.QUANTITY,
			P.PRODUCT_KEY,
			P.PRODUCT_NAME,
			P.CATEGORY,
			P.SUBCATEGORY,
			P.COST
		FROM GOLD.FACT_SALES AS F
		LEFT JOIN GOLD.DIM_PRODUCTS AS P
		ON P.PRODUCT_KEY = F.PRODUCT_KEY
		WHERE ORDER_DATE IS NOT NULL
)
, PRODUCT_AGGREGATION AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
		SELECT 
			PRODUCT_KEY,
			PRODUCT_NAME,
			CATEGORY,
			SUBCATEGORY,
			COST,
			MAX(ORDER_DATE) AS LAST_SALE_DATE,
			COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,
			SUM(SALES_AMOUNT) AS TOTAL_SALES,
			SUM(QUANTITY) AS TOTAL_QUANTITY,
			COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
			EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 
		          + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS life_span,
			ROUND(AVG(CAST(SALES_AMOUNT AS NUMERIC)/ NULLIF(QUANTITY,0)),1) AS AVG_SELLING_PRICE
			
		FROM BASE_QUERY
		GROUP BY 
			PRODUCT_KEY,
			PRODUCT_NAME,
			CATEGORY,
			SUBCATEGORY,
			COST
  )
  /*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
 SELECT 
		PRODUCT_KEY,
		PRODUCT_NAME,
		CATEGORY,
		SUBCATEGORY,
		COST,
		LAST_SALE_DATE,
		EXTRACT(YEAR FROM AGE(CURRENT_DATE, LAST_SALE_DATE)) * 12 
		          + EXTRACT(MONTH FROM AGE(CURRENT_DATE,LAST_SALE_DATE)) AS RECENCY_IN_MONTHS,
		CASE 
				WHEN TOTAL_SALES > 50000 THEN 'HIGH-PERFORMER'
				WHEN TOTAL_SALES >= 5000 THEN 'MID-RANGE'
				ELSE 'LOW-PERFORMER'
			END AS PRODUCT_SEGMENT,
		LIFE_SPAN,
		TOTAL_ORDERS,
		TOTAL_SALES,
		TOTAL_QUANTITY,
		TOTAL_CUSTOMERS,
		AVG_SELLING_PRICE,
		-- COMPUTE AVERAGE ORDER REVENUE (AOR)
		CASE WHEN TOTAL_ORDERS = 0 THEN 0
			ELSE TOTAL_SALES/TOTAL_ORDERS
		END AS AVERAGE_ORDER_REVENUE,
		-- COMPUTE AVERAGE ORDER VALUE (AVD)
		CASE WHEN LIFE_SPAN = 0 THEN TOTAL_SALES
			ELSE TOTAL_SALES/LIFE_SPAN
		END AS AVERAGE_MONTHLY_SPEND
	FROM PRODUCT_AGGREGATION	
)
