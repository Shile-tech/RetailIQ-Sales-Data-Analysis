    USE RetailIQ;
    GO


/*==================================================================================================================================================================
                                         RETAILIQ SALES — EXPLORATORY DATA ANALYSIS
=======================================================================================================================================================================

Purpose:
    This script performs a comprehensive Exploratory Data Analysis (EDA) of the RetailIQ Sales dataset
    to understand sales performance, customer behavior, product performance, returns, subscriptions,
    and key business trends.

Objectives:
    - Explore the structure, quality, and distribution of the data.
    - Analyze key business metrics and KPIs.
    - Identify trends and patterns across customers, products, categories, countries, and time.
    - Evaluate customer purchasing behavior, value, recency, and segmentation.
    - Analyze product sales, pricing, margins, inventory, and performance.
    - Examine returns and subscription-related activities.
    - Perform comparative, trend, and part-to-whole analyses.
    - Develop reusable customer and product reporting views containing actionable business KPIs.

Approach:
    The analysis progresses from high-level data exploration and KPI analysis to deeper customer,
    product, time based, and comparative analysis. SQL techniques including filtering, aggregation,
    joins, CTEs, window functions, conditional logic, date functions, and calculated metrics are used
    to transform the cleaned data into meaningful business insights.

Output:
    The final analysis produces customer and product level reports designed to support business
    decision making, performance monitoring, customer analysis, and identification of growth opportunities.

=====================================================================================================================================================================*/






/*=============================================================================================================
1.    Dimensions Explorations.
===============================================================================================================
Purpose:
    - To explore the structure of dimension tables before performing deep analysis.
	- To identify how they can be grouped and categorized.

SQL Functions Used:
    - DISTINCT
    - ORDER BY
================================================================================================================*/

-- Retrieve a list of distinct categorical values (e.g country,products,categories etc) from a table.

-- customers

SELECT DISTINCT segment
FROM clean.customers
ORDER BY segment;

SELECT DISTINCT region
FROM clean.customers
ORDER BY region;

SELECT DISTINCT country
FROM clean.customers
ORDER BY country;

SELECT DISTINCT industry
FROM clean.customers
ORDER BY industry;

SELECT DISTINCT acquisition_channel
FROM clean.customers
ORDER BY acquisition_channel;


-- products 

SELECT DISTINCT category
FROM clean.products
ORDER BY category;


-- orders

SELECT DISTINCT sales_channel
FROM clean.orders
ORDER BY sales_channel;


SELECT category FROM clean.order_items
-- returns

SELECT DISTINCT return_reason
FROM clean.returns
ORDER BY return_reason;

SELECT DISTINCT return_status
FROM clean.returns
ORDER BY return_status;


-- subcriptions

SELECT DISTINCT plan_name
FROM clean.subscriptions
ORDER BY plan_name;

SELECT DISTINCT payment_method
FROM clean.subscriptions
ORDER BY payment_method;

SELECT DISTINCT cancellation_reason
FROM clean.subscriptions
ORDER BY cancellation_reason;





/*============================================================================================================
2.     Measures Exploration (Key Metrics)  -- BUSINESS SNAPSHOT
==============================================================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
==============================================================================================================*/


-- Generate a Report that shows all key metrics of the business

SELECT 'Total Revenue'                  AS measure_name, SUM(line_total_USD)             AS measure_value FROM clean.order_items
UNION ALL
SELECT 'Avg Product Unit Cost'          AS measure_name, ROUND(AVG(unit_cost_USD),2)     AS measure_value FROM clean.products      
UNION ALL
SELECT 'Avg Product Unit Price'         AS measure_name, ROUND(AVG(unit_price_USD),2)    AS measure_value FROM clean.products     
UNION ALL     
SELECT 'Avg Gross margin pct'           AS measure_name, ROUND(AVG(gross_margin_pct),2)  AS measure_value FROM clean.products      
UNION ALL
SELECT 'Total Inventory Unit'           AS measure_name, SUM(stock_qty)                  AS measure_value FROM clean.products   
UNION ALL
SELECT 'Inventory Cost Value'           AS measure_name, (stock_qty * unit_cost_USD)     AS measure_value FROM clean.products  
UNION ALL
SELECT 'Inventory Resale Value'         AS measure_name, (stock_qty * unit_price_USD)    AS measure_value FROM clean.products    
UNION ALL
SELECT 'Avg Shipping Cost per Order'    AS measure_name, ROUND(AVG(shipping_cost_USD),2) AS measure_value FROM clean.orders        
UNION ALL
SELECT 'Total Quantity Sold'            AS measure_name, SUM(quantity)                   AS measure_value FROM clean.order_items
UNION ALL
SELECT 'Total Processed refunds amount' AS measure_name, SUM(refund_amount_USD)          AS measure_value FROM clean.returns       WHERE return_status = 'Processed'
UNION ALL
SELECT 'Total Pending Refund Amount'    AS measure_name, SUM(refund_amount_USD)          AS measure_value FROM clean.returns       WHERE return_status = 'Pending'
UNION ALL
SELECT 'Avg Monthly subscription fee '  AS measure_name, AVG(monthly_fee_USD)            AS measure_value FROM clean.subscriptions 
UNION ALL
SELECT 'Avg Sub_lifespan Month'         AS measure_name, AVG(derived_tenure_months)      AS measure_value FROM clean.subscriptions 
UNION ALL
SELECT 'Total subscription revenue'     AS measure_name, SUM(total_revenue_USD)          AS measure_value FROM clean.subscriptions
UNION ALL
SELECT 'Total Number of customers'      AS measure_name, COUNT(DISTINCT customer_id)     AS measure_value FROM clean.customers
UNION ALL
SELECT'Total Active customers'          AS measure_name, COUNT(DISTINCT customer_id)     AS measure_value FROM clean.customers     WHERE activity_status <> 'Churned' AND activity_status IS NOT NULL
UNION ALL
SELECT 'Total products'                 AS measure_name, COUNT(DISTINCT product_id)      AS measure_value FROM clean.products
UNION ALL
SELECT 'Total Orders'                   AS measure_name, COUNT(DISTINCT order_id)        AS measure_value FROM clean.orders
UNION ALL
SELECT 'Ttl_ord succ_returned'          AS measure_name, COUNT(DISTINCT order_id)        AS measure_value FROM clean.returns       WHERE return_status = 'Processed'
UNION ALL
SELECT 'Total Subscriptions'            AS measure_name, COUNT(DISTINCT subscription_id) AS measure_value FROM clean.subscriptions
UNION ALL
SELECT 'Total Active_subs'              AS measure_name, COUNT(DISTINCT subscription_id) AS measure_value FROM clean.subscriptions WHERE subscription_status = 'Active';





/*===============================================================================================================
3.     Date Range Exploration 
=================================================================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
================================================================================================================*/

-- Lifespan of customers 

SELECT 
    customer_id,
    CONCAT(first_name,' ',last_name) AS full_name,
    acquisition_date,          
    last_purchase_date,
    DATEDIFF(MONTH,acquisition_date,last_purchase_date) AS customer_purchase_lifespan_month
FROM clean.customers
ORDER BY customer_purchase_lifespan_month DESC;


-- Company's first and last order_dates

SELECT
    MIN(order_date)   AS first_order,
    MAX(order_date)   AS last_order,
    DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS purchasing_period_months
FROM clean.orders;


-- Monthly sales.

WITH monthly_sales AS
(
SELECT
    YEAR(order_date)                    AS year_,
    MONTH(order_date)                   AS mnth_int,
    DATENAME(MONTH,order_date)          AS month_,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue,
    COUNT(DISTINCT o.order_id)          AS total_orders
FROM clean.orders o
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY YEAR(order_date),
         MONTH(order_date), 
         DATENAME(MONTH,order_date)
)

SELECT
    year_,
    month_,
    total_revenue,
    total_orders
FROM monthly_sales
ORDER BY year_,
         mnth_int;  


-- Orders with return dates earlier than thier order date

SELECT *
FROM clean.returns r
LEFT JOIN clean.orders o
    ON r.order_id = o.order_id
WHERE r.order_id_flag = 'Valid FK'
  AND r.return_date < o.order_date;                       -- return_dates before an order_date


-- Date metrics on returns

SELECT
    r.return_reason,
    COUNT(*)                                             AS total_returns,
    AVG(DATEDIFF(DAY, o.order_date, r.return_date))      AS avg_days_to_return,
    MIN(DATEDIFF(DAY, o.order_date, r.return_date))      AS min_days_to_return,
    MAX(DATEDIFF(DAY, o.order_date, r.return_date))      AS max_days_to_return
FROM clean.returns r
INNER JOIN clean.orders o
    ON r.order_id = o.order_id
WHERE r.order_id_flag = 'Valid FK'
AND   DATEDIFF(DAY, o.order_date, r.return_date) >= 0
GROUP BY r.return_reason
ORDER BY avg_days_to_return DESC ;                 





/*==============================================================================================================
4.      Magnitude Analysis
================================================================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
================================================================================================================*/

--              REVENUE

-- Total Revenue by countries

SELECT
    c.country,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.country
ORDER BY total_revenue DESC;


-- Total revenue generated by category?

SELECT
    category,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue
FROM clean.order_items
GROUP BY category
ORDER BY total_revenue DESC;


-- Total Revenue by region

SELECT
    c.region,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.region
ORDER BY total_revenue DESC;


-- Total products by category

SELECT
    category,
    COUNT(DISTINCT product_id) AS total_products
FROM clean.products
GROUP BY category
ORDER BY total_products DESC;


-- Average costs,price and margin by category?

SELECT
    category,
    ROUND(AVG(unit_cost_USD),2)     AS avg_cost,
    ROUND(AVG(unit_price_USD),2)    AS avg_price,
    ROUND(AVG(gross_margin_pct), 2) AS avg_margin
FROM clean.products
GROUP BY category
ORDER BY avg_cost   DESC,
         avg_price  DESC,
         avg_margin DESC;


-- What is the distribution of sold items across countries and also the total orders?

SELECT
    c.country,
    COUNT(DISTINCT o.order_id)   AS total_orders,
    COALESCE(SUM(oi.quantity),0) AS total_sold_items
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.country
ORDER BY total_sold_items DESC;


-- Total customers by countries

SELECT
    country,
    COUNT(DISTINCT customer_id) AS total_customers
FROM clean.customers
GROUP BY country
ORDER BY total_customers DESC;


-- Total revenue by activity status

SELECT 
    activity_status,
    COUNT(DISTINCT c.customer_id)       AS total_customers,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue,
    ROUND(AVG(oi.line_total_USD), 2)    AS avg_revenue_per_customer
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY activity_status
ORDER BY total_revenue DESC;





/*=============================================================================================================
5.     Ranking Analysis
=================================================================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
================================================================================================================*/

-- Which 10 products Generating the Highest Revenue?

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue
FROM clean.products p
INNER JOIN clean.order_items oi 
     ON p.product_id = oi.product_id
GROUP BY p.product_id,
         p.product_name,
         p.category
ORDER BY total_revenue DESC;


-- Using windows functions.
-- Demostrating both approach to show my understanding of window functions, also used DENSE_RANK because it handles ties and doesnt leave gaps in the rank.

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category, 
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(oi.line_total_USD) DESC) AS rank_
FROM clean.products p
INNER JOIN clean.order_items oi 
     ON p.product_id = oi.product_id
GROUP BY p.product_id,
         p.product_name,
         p.category
ORDER BY total_revenue DESC;


-- What are the 5 worst performing products in terms of sales?

SELECT TOP 5
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue
FROM clean.products p
INNER JOIN clean.order_items oi 
     ON p.product_id = oi.product_id
GROUP BY p.product_id,
         p.product_name,
         p.category
ORDER BY total_revenue;


-- Find the top 10 customers who have generated the highest revenue

SELECT TOP 10
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS full_name,
    c.region,
    c.segment,
    c.activity_status,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    COALESCE(SUM(oi.line_total_USD), 0)      AS total_revenue,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(oi.line_total_USD), 0) DESC) AS rank_
FROM clean.customers c
INNER JOIN clean.orders o
     ON c.customer_id = o.customer_id
INNER JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name,
         c.region,
         c.segment,
         c.activity_status
ORDER BY total_revenue DESC;


-- The 3 customers with the fewest orders placed

SELECT TOP 3
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS full_name,
    c.activity_status,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name,
         c.activity_status
ORDER BY total_orders ;





/*===============================================================================================================
6.     Change Over Time Analysis
================================================================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================================================*/

-- DATETRUNC() to see sales by months over time.

SELECT
    DATETRUNC(MONTH,o.order_date)       AS order_month,
    COALESCE(SUM(oi.line_total_USD),0)  AS total_revenue,
    COUNT(DISTINCT o.customer_id)       AS total_customers,
    COALESCE(SUM(oi.quantity),0)        AS total_quantity
FROM clean.orders o
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY DATETRUNC(MONTH,o.order_date)
ORDER BY DATETRUNC(MONTH,o.order_date);


-- Yearly revenue over time.     
-- Note: YoY growth percentage calculated in Metric 8

SELECT
    YEAR(o.order_date)                  AS year_,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COALESCE(SUM(oi.quantity),0)        AS total_quantity
FROM clean.orders o
LEFT JOIN clean. order_items oi
     ON o.order_id = oi.order_id 
GROUP BY YEAR(o.order_date)
ORDER BY YEAR(o.order_date);       





/*================================================================================================================
7.     Cumulative Analysis
==================================================================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================================================*/

-- Total monthly sales, running total and average price over time.


WITH running_total AS 
(
SELECT
    DATETRUNC(MONTH,o.order_date)       AS order_month,    
    COUNT(DISTINCT o.customer_id)       AS total_customers,
    COALESCE(SUM(oi.quantity),0)        AS total_quantity_ordered,
    COALESCE(SUM(oi.line_total_USD), 0) AS total_revenue,
    AVG(oi.unit_price_USD)              AS avg_price
FROM clean.orders o
INNER JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY DATETRUNC(MONTH,o.order_date)
)

SELECT 
    order_month,
    total_customers,
    total_quantity_ordered,
    total_revenue,
    SUM(total_revenue) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)            AS running_total,
    avg_price,
    SUM(total_revenue) OVER (ORDER BY order_month) / NULLIF(SUM(total_quantity) OVER (ORDER BY order_month),0) AS weighted_moving_average_price,
    AVG(avg_price) OVER (ORDER BY order_month) AS moving_average_price
FROM running_total  
ORDER BY order_month;

-- weighted_moving_average_price: true cumulative avg weighted by quantity sold.
-- moving_average_price: simple cumulative avg of monthly averages —- for trend comparison.





/*===============================================================================================================
8.           Performance Analysis (Year-over-Year, Month-over-Month)
=================================================================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
=================================================================================================================*/

/* Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales */

WITH yearly_product_sales AS 
(
SELECT
    YEAR(o.order_date) AS order_year,
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.line_total_USD),0) AS current_sales
FROM clean.orders o
INNER JOIN clean.order_items oi
     ON o.order_id = oi.order_id
INNER JOIN clean.products p
     ON oi.product_id= p.product_id
GROUP BY YEAR(o.order_date),
         P.product_id,
         p.product_name
),

performance_calc AS
(
SELECT
    order_year,
    product_id,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_id)                                     AS avg_sales,
 -- Current sales to average analysis  
    current_sales - AVG(current_sales) OVER (PARTITION BY product_id)                     AS current_avg_diff,
 -- Year-over-Year Analysis    
    LAG(current_sales) OVER (PARTITION BY product_id ORDER BY order_year)                 AS prev_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_id ORDER BY order_year) AS yearly_diff
FROM yearly_product_sales
)

SELECT
    order_year,
    product_id,
    product_name,
    current_sales,
    avg_sales,
 -- Current sales to average sales analysis  
    current_avg_diff,
    CASE 
        WHEN current_avg_diff > 0 THEN 'Above Avg'
        WHEN current_avg_diff < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change_flag,
 -- Year-over-Year Analysis
    current_sales,
    prev_year_sales,
    yearly_diff,
    CASE 
        WHEN yearly_diff > 0      THEN 'Increase'
        WHEN yearly_diff < 0      THEN 'Decrease'
        WHEN yearly_diff IS NULL  THEN 'No Prev_year_record'
        ELSE 'No Change'
    END AS yearly_change_flag,
    ROUND((CAST(yearly_diff AS FLOAT) / NULLIF(prev_year_sales,0)) * 100,2) AS yoy_growth_pct
FROM performance_calc
ORDER BY product_id,
         order_year;





/*===============================================================================================================
9.     Data Segmentation Analysis
=================================================================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.

Stakeholder's defined segmentation criteria :

    Price  :
           - 'Below 500'
           - '500 - 999.99'
           - '1k - 3k'
           - 'Above 3k'


 Customers :
           - No purchase : Customers with no recorded transaction spending.
	       - VIP: Customers with at least 36 months of history and spending more than $500,000.
	       - Regular: Customers with at least 36 months of history but spending $500,000 or less.
           - New and spending : customer with a lifespan less than 36 months and spending above $500,000
           - New: Customers with a lifespan less than 36 months and spending $500,000 or less.
=================================================================================================================*/

-- Segment products into price ranges and count how many products fall into each segment.

WITH product_segments AS 
(
SELECT
    product_id,
    unit_price_USD,
    CASE 
        WHEN unit_price_USD < 500                             THEN 'Below 500.00'
        WHEN unit_price_USD >= 500 AND unit_price_USD < 1000  THEN '500.00 - 999.99'
        WHEN unit_price_USD BETWEEN 1000 AND 3000             THEN '1k - 3k'
        ELSE                                                       'Above 3k'
    END     AS price_range
FROM clean.products
)

SELECT 
    price_range,
    COUNT(DISTINCT product_id) AS total_products
FROM product_segments
GROUP BY price_range
ORDER BY total_products DESC;



/* Group customers into four segments based on their spending behavior:
      - No purchase : Customers with no recorded transaction spending.
	  - VIP: Customers with at least 36 months of history and spending more than $500,000.
	  - Regular: Customers with at least 36 months of history but spending $500,000 or less.
      - New and spending : customer with a lifespan less than 36 months and spending above $500,000
      - New: Customers with a lifespan less than 36 months and spending $500,000 or less.
   And find the total number of customers by each group */


WITH customer_spending AS 
(
SELECT
    c.customer_id,
    COALESCE(SUM(oi.line_total_USD),0) AS total_spend,
    c.acquisition_date,
    c.last_purchase_date,
    DATEDIFF(MONTH, c.acquisition_date, c.last_purchase_date) AS lifespan
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.customer_id,
         c.acquisition_date,
         c.last_purchase_date
),

customer_segmentation AS
(
SELECT
    CASE 
        WHEN total_spend = 0                           THEN 'No Purchase'
        WHEN lifespan >= 36 AND total_spend >  500000  THEN 'Vip'
        WHEN lifespan >= 36 AND total_spend <= 500000  THEN 'Regular'
        WHEN lifespan  < 36 AND total_spend >  500000  THEN 'New and Spending'
        ELSE                                                'New'                                                
    END          AS customer_segment,
    customer_id 
FROM customer_spending
)

SELECT
    customer_segment,
    COUNT(customer_id) AS total_customer
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customer DESC;





/*==============================================================================================================
10.         Part-to-Whole Analysis
================================================================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================================================*/

-- Which category contribute the most to overall sales?

WITH revenue_category AS 
(
SELECT
    category,
    COALESCE(SUM(oi.line_total_USD),0) AS total_revenue
FROM clean.order_items
GROUP BY category
)

SELECT
    category,
    total_revenue,
    SUM(total_revenue) OVER () AS overall_revenue,
    ROUND((CAST(total_revenue AS FLOAT) / NULLIF(SUM(total_revenue) OVER (),0)) * 100, 2) AS percentage_of_total
FROM revenue_category
ORDER BY total_revenue DESC;



-- Top 10 countries that contributed most to overall company's revenue.

WITH country_spending AS 
(
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)      AS total_customers,
    COALESCE(SUM(oi.line_total_USD),0) AS total_revenue
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id
GROUP BY c.country
)

SELECT TOP 10
    country,
    total_customers,
    total_revenue,
    SUM(total_revenue) OVER ()   AS overall_revenue,
    ROUND((CAST(total_revenue AS FLOAT) / SUM(total_revenue) OVER ()) * 100.0,2) AS percentage_of_total
FROM country_spending
ORDER BY percentage_of_total DESC;





/*=============================================================================================================
11.      Customer Report
================================================================================================================
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
=================================================================================================================*/



-- ===============================================================================================================
-- Create Report: clean.report_customers
-- =============================================================================================================

IF OBJECT_ID('clean.report_customers', 'V') IS NOT NULL
    DROP VIEW clean.report_customers;
GO

CREATE VIEW clean.report_customers AS


WITH base_query AS                     -- 1) Base Query: Retrieves core columns from tables
(
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.segment,
    c.country,
    c.industry,
    c.acquisition_channel,
    c.activity_status,
    c.acquisition_date,
    c.last_purchase_date,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.line_total_USD,
    oi.quantity
FROM clean.customers c
LEFT JOIN clean.orders o
     ON c.customer_id = o.customer_id
LEFT JOIN clean.order_items oi
     ON o.order_id = oi.order_id       
),

customer_aggregation AS              -- 2) Customer Aggregations: Summarizes key metrics at the customer level
(
SELECT 
	customer_id,
	customer_name,
	segment,
    country,
    industry,
    acquisition_channel,
    activity_status,
	COUNT(DISTINCT order_id)        AS total_orders,
	COALESCE(SUM(line_total_USD),0) AS total_order_revenue,      
	SUM(quantity)                   AS total_quantity,
	COUNT(DISTINCT product_id)      AS total_products_ordered,
    MIN(order_date)                 AS first_order_date,
	MAX(order_date)                 AS last_order_date,
	DATEDIFF(MONTH,acquisition_date,last_purchase_date)  AS customer_lifespan_month
FROM base_query
GROUP BY customer_id,
         customer_name,
         segment,
         country,
         industry,
         acquisition_channel,
         activity_status,
         acquisition_date,
         last_purchase_date
)

SELECT
    customer_id,
    customer_name,
    segment,
    country,
    industry,
    acquisition_channel,
    activity_status,
    CASE 
        WHEN total_order_revenue = 0                                          THEN 'No Purchase'
        WHEN customer_lifespan_month >= 36 AND total_order_revenue >  500000  THEN 'Vip'
        WHEN customer_lifespan_month >= 36 AND total_order_revenue <= 500000  THEN 'Regular'
        WHEN customer_lifespan_month  < 36 AND total_order_revenue >  500000  THEN 'New and Spending'
        ELSE                                                                       'New'                                                
    END          AS customer_segment,
    customer_lifespan_month,
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_month,
    total_order_revenue,
    total_orders,
 -- Compute average order value (AVO)
    ROUND((CAST(total_order_revenue AS FLOAT) / NULLIF(total_orders,0)),2) AS avg_order_value,
 -- Compute average monthly spend
    total_order_revenue / NULLIF(customer_lifespan_month,0) AS avg_monthly_spend,
    total_quantity,
 -- Compuate average order quantity
    ROUND((CAST(total_quantity AS FLOAT) / NULLIF(total_orders,0)),2) AS avg_order_quantity,
 -- Compuate average monthly order quantity
    total_quantity / NULLIF(customer_lifespan_month,0) AS avg_monthly_order_quantity,
    total_products_ordered
FROM customer_aggregation;






/*================================================================================================================
12.      Product Report
==================================================================================================================
Purpose :
    - This report consolidates key product metrics and behaviors.

Highlights :
    1. Gathers essential fields such as product name, category, subcategory, and cost.

    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low Performers.

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
=================================================================================================================*/



-- =============================================================================
-- Create Report: clean.report_products
-- =============================================================================

IF OBJECT_ID('clean.report_products', 'V') IS NOT NULL
    DROP VIEW clean.report_products;
GO

CREATE VIEW clean.report_products AS

WITH base_query AS                           -- 1) Base Query: Retrieves core columns from tables.
(
SELECT
    p.product_id,
    o.order_id,
    o.customer_id,
    p.product_name,
    p.category,
    p.unit_cost_USD  AS unit_production_cost,
    p.unit_price_USD,
    p.gross_margin_pct,
    p.stock_qty AS inventory,
    oi.quantity AS unit_sold,
    oi.discount_pct,
    oi.line_total_USD,
    CASE
        WHEN p.unit_price_USD IS NOT NULL AND oi.discount_pct IS NOT NULL AND oi.quantity IS NOT NULL THEN ROUND((p.unit_price_USD * oi.quantity) * (1 - (oi.discount_pct / 100.0)),2)
        ELSE oi.line_total_USD
    END   AS derived_line_total_USD,         -- data richness.
    o.order_date,
    o.sales_channel,
    o.country,
    p.is_active
FROM clean.products p
LEFT JOIN clean.order_items oi
     ON p.product_id = oi.product_id
LEFT JOIN clean.orders o
     ON oi.order_id = o.order_id
),

product_aggregations AS                     -- 2) Product Aggregations: Summarizes key metrics at the product level
(
SELECT
    product_id,
    product_name,
    category,
    unit_production_cost,
    unit_price_USD,
    gross_margin_pct,
    inventory,
    is_active                                         AS availability_of_product,
    COUNT(DISTINCT sales_channel)                     AS total_sales_channel_utilized,
    COUNT(DISTINCT country)                           AS total_country_ordered_from,
    COALESCE(DATEDIFF(MONTH, MIN(order_date), MAX(order_date)), 0) AS product_lifespan_month,
    MAX(order_date)                                   AS last_sale_date,
    COUNT(DISTINCT order_id)                          AS total_orders,
	COUNT(DISTINCT customer_id)                       AS total_customers,
    SUM(derived_line_total_USD)                       AS total_sales,
    SUM(unit_sold)                                    AS total_quantity,
    AVG(discount_pct)                                 AS avg_discount
FROM base_query
GROUP BY    product_id,
            product_name,
            category,
            unit_production_cost,
            unit_price_USD,
            gross_margin_pct,
            inventory,
            is_active
)

SELECT                                        -- 3) Final Query: Combines all product results into one output
    product_id,
    product_name,
    category,
    unit_production_cost,
    unit_price_USD,
    gross_margin_pct,
    inventory,
    total_sales_channel_utilized,
    total_country_ordered_from,
    availability_of_product,
    avg_discount,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	total_sales,
	CASE
		WHEN total_sales >= 1500000  THEN 'High Performer'
		WHEN total_sales >= 500000   THEN 'Mid Range'
		ELSE                              'Low Performer'
	END           AS product_segment,
	product_lifespan_month,
	total_orders,
	total_quantity,
	total_customers,
 -- Average Order Revenue (AOR)
    ROUND(CAST(total_sales AS FLOAT) / NULLIF(total_orders,0),2)   AS avg_order_revenue,
 -- Average Monthly Revenue
    ROUND(CAST(total_sales AS FLOAT) / NULLIF(product_lifespan_month,0),2) AS avg_monthly_revenue
FROM product_aggregations;



