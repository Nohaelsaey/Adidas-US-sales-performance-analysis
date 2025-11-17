-- 1. Create the Database if not exists and use it
CREATE DATABASE IF NOT EXISTS adidas_sales_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE adidas_sales_db;

-- 2. Create Dimension Tables

CREATE TABLE dim_retailer (
  retailer_id INT PRIMARY KEY AUTO_INCREMENT,
  retailer_name VARCHAR(255),
  city VARCHAR(255),
  state VARCHAR(100),
  region VARCHAR(100),
  sales_method VARCHAR(100)
);

CREATE TABLE dim_product (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(255),
  category VARCHAR(100)
);
ALTER TABLE dim_product
DROP COLUMN category;

CREATE TABLE dim_date (
  date_id INT PRIMARY KEY AUTO_INCREMENT,
  full_date DATE,
  year INT,
  quarter INT,
  month INT,
  day_of_week INT
);

-- 3. Create Fact Table

CREATE TABLE fact_sales (
  sales_id INT PRIMARY KEY AUTO_INCREMENT,
  retailer_id INT,
  product_id INT,
  date_id INT,
  total_sales DECIMAL(15,2),
  operating_profit DECIMAL(15,2),
  units_sold INT,
  price_per_unit DECIMAL(10,2),
  FOREIGN KEY (retailer_id) REFERENCES dim_retailer(retailer_id),
  FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- 4. Example Inserts: Distinct values into dimensions (adjust columns as per your source data)

INSERT INTO dim_retailer (retailer_name, city, state, region, sales_method)
SELECT DISTINCT retailer, city, state, region, sales_method FROM adidasus;

INSERT INTO dim_product (product_name)
SELECT DISTINCT product FROM adidasus;

INSERT INTO dim_date (full_date, year, quarter, month, day_of_week)
SELECT DISTINCT 
  STR_TO_DATE(invoice_date, '%c/%e/%Y'), 
  YEAR(STR_TO_DATE(invoice_date, '%c/%e/%Y')), 
  QUARTER(STR_TO_DATE(invoice_date, '%c/%e/%Y')),
  MONTH(STR_TO_DATE(invoice_date, '%c/%e/%Y')),
  DAYOFWEEK(STR_TO_DATE(invoice_date, '%c/%e/%Y'))
FROM adidasus;

-- 5. Insert into fact table with $ removal and numeric conversion, join with dimension tables to get keys

INSERT INTO fact_sales (retailer_id, product_id, date_id, total_sales, operating_profit, units_sold, price_per_unit)
SELECT 
  r.retailer_id,
  p.product_id,
  d.date_id,
  CAST(REPLACE(a.total_sales, '$', '') AS DECIMAL(15,2)) AS total_sales,
  CAST(REPLACE(a.operating_profit, '$', '') AS DECIMAL(15,2)) AS operating_profit,
  a.units_sold,
  CAST(REPLACE(a.price_per_unit, '$', '') AS DECIMAL(10,2)) AS price_per_unit
FROM adidasus a
JOIN dim_retailer r ON a.retailer = r.retailer_name
JOIN dim_product p ON a.product = p.product_name
JOIN dim_date d ON STR_TO_DATE(a.invoice_date, '%c/%e/%Y') = d.full_date;

SELECT DISTINCT units_sold FROM adidasus WHERE units_sold IS NOT NULL ORDER BY units_sold;
ALTER TABLE fact_sales MODIFY COLUMN units_sold DECIMAL(10, 2);
INSERT INTO fact_sales (retailer_id, product_id, date_id, total_sales, operating_profit, units_sold, price_per_unit)
SELECT 
  r.retailer_id,
  p.product_id,
  d.date_id,
  CAST(REPLACE(a.total_sales, '$', '') AS DECIMAL(15,2)) AS total_sales,
  CAST(REPLACE(a.operating_profit, '$', '') AS DECIMAL(15,2)) AS operating_profit,
  CAST(CAST(a.units_sold AS DECIMAL(10, 2)) AS SIGNED) AS units_sold,
  CAST(REPLACE(a.price_per_unit, '$', '') AS DECIMAL(10,2)) AS price_per_unit
FROM adidasus a
JOIN dim_retailer r ON a.retailer = r.retailer_name
JOIN dim_product p ON a.product = p.product_name
JOIN dim_date d ON STR_TO_DATE(a.invoice_date, '%c/%e/%Y') = d.full_date;

select * from dim_retailer;
select * from dim_product;
select * from dim_date;
select * from fact_sales;
