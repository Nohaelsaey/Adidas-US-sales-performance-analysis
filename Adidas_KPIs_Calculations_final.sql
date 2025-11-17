use adidas;

select * from adidasus;
SELECT COUNT(*) FROM adidasus;

--------------------------------------------------------------
-- Here are the modified SQL KPI queries with clear structure:
--------------------------------------------------------------

-- Total Sales Revenue:
SELECT 
  SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10,2))) AS total_sales_revenue
FROM adidasus;

-- Total Units Sold
SELECT 
  SUM(units_sold) AS total_units_sold
FROM adidasus;

-- Average Price Per Unit
SELECT 
  ROUND(AVG(CAST(REPLACE(price_per_unit, '$', '') AS DECIMAL(10, 2))), 2) AS avg_price_per_unit
FROM adidasus;

-- Gross Operating Profit
SELECT 
  SUM(CAST(REPLACE(operating_profit, '$', '') AS DECIMAL(10, 2))) AS total_operating_profit
FROM adidasus;

--  Sales by Region
SELECT 
  region, 
  SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10, 2))) AS total_sales_by_region
FROM adidasus
GROUP BY region
ORDER BY total_sales_by_region DESC;

-- Sales by Product
SELECT 
  product, 
  SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10, 2))) AS total_sales_by_product
FROM adidasus
GROUP BY product
ORDER BY total_sales_by_product DESC

-- Sales by Retailer and Sales Method
SELECT 
  retailer, 
  sales_method, 
  SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10, 2))) AS total_sales,
  SUM(CAST(REPLACE(operating_profit, '$', '') AS DECIMAL(10, 2))) AS total_profit
FROM adidasus
GROUP BY retailer, sales_method
ORDER BY total_sales DESC;

-- Monthly Sales Trend by Invoice Date
-- we had an issue of format in the column of invoice_date, so we added new column with the exact formatting for aggregation.
ALTER TABLE adidasus
ADD COLUMN invoice_date_clean DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE adidasus
SET invoice_date_clean = STR_TO_DATE(invoice_date, '%c/%e/%Y')
WHERE invoice_date IS NOT NULL AND invoice_date != '';

SELECT 
  DATE_FORMAT(invoice_date_clean, '%Y-%m') AS sales_month, 
  SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10, 2))) AS monthly_sales
FROM adidasus
WHERE invoice_date_clean IS NOT NULL
GROUP BY sales_month
ORDER BY sales_month;

-- Monthly Sales Growth Rate (compared to previous month)
WITH monthly_sales AS (
  SELECT 
    DATE_FORMAT(STR_TO_DATE(invoice_date, '%c/%e/%Y'), '%Y-%m') AS sales_month, 
    SUM(CAST(REPLACE(total_sales, '$', '') AS DECIMAL(10, 2))) AS monthly_sales
  FROM adidasus
  GROUP BY sales_month
)
SELECT 
  sales_month,
  monthly_sales,
  ROUND((monthly_sales - LAG(monthly_sales) OVER (ORDER BY sales_month)) / NULLIF(LAG(monthly_sales) OVER (ORDER BY sales_month), 0), 4) AS growth_rate
FROM monthly_sales
ORDER BY sales_month;


