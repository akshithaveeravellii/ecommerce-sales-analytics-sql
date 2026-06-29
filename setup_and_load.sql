-- ============================================================
-- E-Commerce Sales & KPI Analytics
-- 1 Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Tool: MySQL / PostgreSQL compatible
-- ============================================================
-- STEP 1: Create database and tables
-- ============================================================

CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id           VARCHAR(50) PRIMARY KEY,
    customer_unique_id    VARCHAR(50),
    customer_zip_code     VARCHAR(10),
    customer_city         VARCHAR(100),
    customer_state        VARCHAR(5)
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id                        VARCHAR(50) PRIMARY KEY,
    customer_id                     VARCHAR(50),
    order_status                    VARCHAR(30),
    order_purchase_timestamp        DATETIME,
    order_approved_at               DATETIME,
    order_delivered_carrier_date    DATETIME,
    order_delivered_customer_date   DATETIME,
    order_estimated_delivery_date   DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items table
CREATE TABLE IF NOT EXISTS order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Payments table
CREATE TABLE IF NOT EXISTS order_payments (
    order_id                VARCHAR(50),
    payment_sequential      INT,
    payment_type            VARCHAR(30),
    payment_installments    INT,
    payment_value           DECIMAL(10,2)
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name       VARCHAR(100),
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            DECIMAL(10,2),
    product_length_cm           DECIMAL(10,2),
    product_height_cm           DECIMAL(10,2),
    product_width_cm            DECIMAL(10,2)
);

-- Category name translation table
CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name           VARCHAR(100),
    product_category_name_english   VARCHAR(100)
);

-- Sellers table
CREATE TABLE IF NOT EXISTS sellers (
    seller_id           VARCHAR(50) PRIMARY KEY,
    seller_zip_code     VARCHAR(10),
    seller_city         VARCHAR(100),
    seller_state        VARCHAR(5)
);

-- Order Reviews table
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INT,
    review_comment_title    VARCHAR(255),
    review_comment_message  TEXT,
    review_creation_date    DATETIME,
    review_answer_timestamp DATETIME
);

-- ============================================================
-- STEP 2: Load CSV data (run these from MySQL command line)
-- Replace the file path with wherever you downloaded the dataset
-- ============================================================

/*
LOAD DATA INFILE '/your/path/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status,
 @purchase, @approved, @carrier, @delivered, @estimated)
SET
  order_purchase_timestamp      = NULLIF(@purchase, ''),
  order_approved_at             = NULLIF(@approved, ''),
  order_delivered_carrier_date  = NULLIF(@carrier, ''),
  order_delivered_customer_date = NULLIF(@delivered, ''),
  order_estimated_delivery_date = NULLIF(@estimated, '');

LOAD DATA INFILE '/your/path/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/your/path/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- ============================================================
-- STEP 3: Verify data loaded correctly
-- ============================================================

SELECT 'customers'   AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',       COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',  COUNT(*) FROM order_items
UNION ALL
SELECT 'payments',     COUNT(*) FROM order_payments
UNION ALL
SELECT 'products',     COUNT(*) FROM products
UNION ALL
SELECT 'sellers',      COUNT(*) FROM sellers
UNION ALL
SELECT 'reviews',      COUNT(*) FROM order_reviews;
