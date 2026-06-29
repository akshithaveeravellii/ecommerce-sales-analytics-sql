-- ============================================================
-- E-Commerce Sales & KPI Analytics
-- 2: Data Cleaning
-- ============================================================

-- ============================================================
-- SECTION A: Inspect for quality issues
-- ============================================================

-- Check for NULL values in orders
SELECT
    COUNT(*)                                                    AS total_orders,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END)       AS null_status,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)        AS null_customer,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date
FROM orders;

-- Check order status distribution
SELECT
    order_status,
    COUNT(*)                            AS order_count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Check for duplicate order_ids
SELECT order_id, COUNT(*) AS count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check for negative or zero prices in order_items
SELECT COUNT(*) AS bad_price_rows
FROM order_items
WHERE price <= 0 OR freight_value < 0;

-- Check products with no category name
SELECT COUNT(*) AS products_without_category
FROM products
WHERE product_category_name IS NULL OR product_category_name = '';

-- Check payment values
SELECT
    MIN(payment_value)  AS min_payment,
    MAX(payment_value)  AS max_payment,
    AVG(payment_value)  AS avg_payment,
    COUNT(*)            AS total_payment_rows
FROM order_payments;

-- ============================================================
-- SECTION B: Create a clean master view for all analysis
-- This joins all tables and filters to only delivered orders
-- ============================================================

CREATE OR REPLACE VIEW vw_clean_orders AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- Delivery performance
    DATEDIFF(
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    )                                                               AS delivery_delay_days,

    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        WHEN o.order_delivered_customer_date >  o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'Unknown'
    END                                                             AS delivery_status,

    -- Product info
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized')
                                                                    AS category_english,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value)                                   AS item_total,

    -- Payment info
    pay.payment_type,
    pay.payment_installments,
    pay.payment_value,

    -- Seller info
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    -- Review info
    r.review_score,

    -- Time dimensions (useful for Tableau)
    YEAR(o.order_purchase_timestamp)                                AS order_year,
    MONTH(o.order_purchase_timestamp)                               AS order_month,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')                AS order_year_month,
    DAYNAME(o.order_purchase_timestamp)                             AS order_day_of_week,
    QUARTER(o.order_purchase_timestamp)                             AS order_quarter

FROM orders o
JOIN customers       c   ON o.customer_id   = c.customer_id
JOIN order_items     oi  ON o.order_id      = oi.order_id
JOIN products        p   ON oi.product_id   = p.product_id
LEFT JOIN product_category_translation t
                         ON p.product_category_name = t.product_category_name
JOIN order_payments  pay ON o.order_id      = pay.order_id
                        AND pay.payment_sequential = 1      -- avoid row duplication from multiple payment methods
LEFT JOIN sellers    s   ON oi.seller_id    = s.seller_id
LEFT JOIN order_reviews r ON o.order_id     = r.order_id

WHERE o.order_status = 'delivered'                          -- only completed orders
  AND o.order_delivered_customer_date IS NOT NULL
  AND oi.price > 0;                                         -- remove bad price rows

-- Quick check on the clean view
SELECT COUNT(*) AS clean_row_count FROM vw_clean_orders;
SELECT COUNT(DISTINCT order_id) AS unique_orders FROM vw_clean_orders;
