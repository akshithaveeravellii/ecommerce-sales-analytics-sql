-- ============================================================
-- E-Commerce Sales & KPI Analytics
-- 4: Tableau Export Queries
-- Run each query and export as CSV → load into Tableau
-- ============================================================

-- ============================================================
-- EXPORT 1: monthly_revenue_trend.csv
-- Powers: Line chart — Revenue over time with MoM growth
-- ============================================================

WITH monthly AS (
    SELECT
        order_year_month,
        order_year,
        order_month,
        ROUND(SUM(payment_value), 2)        AS revenue,
        COUNT(DISTINCT order_id)            AS orders
    FROM vw_clean_orders
    GROUP BY order_year_month, order_year, order_month
)
SELECT
    order_year_month,
    order_year,
    order_month,
    revenue,
    orders,
    LAG(revenue) OVER (ORDER BY order_year_month)   AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year_month))
        * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year_month), 0),
    2)                                              AS mom_growth_pct
FROM monthly
ORDER BY order_year_month;

-- ============================================================
-- EXPORT 2: category_performance.csv
-- Powers: Bar chart — Top categories by revenue and volume
-- ============================================================

SELECT
    category_english,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_value), 2)        AS avg_order_value,
    ROUND(AVG(review_score), 2)         AS avg_review_score
FROM vw_clean_orders
GROUP BY category_english
ORDER BY total_revenue DESC;

-- ============================================================
-- EXPORT 3: state_map.csv
-- Powers: Filled map — Revenue by Brazilian state
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id)  AS unique_customers,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_value), 2)        AS avg_order_value,
    ROUND(AVG(review_score), 2)         AS avg_review
FROM vw_clean_orders
GROUP BY customer_state
ORDER BY total_revenue DESC;

-- ============================================================
-- EXPORT 4: payment_breakdown.csv
-- Powers: Pie / donut chart — Payment method share
-- ============================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM vw_clean_orders
GROUP BY payment_type
ORDER BY total_orders DESC;

-- ============================================================
-- EXPORT 5: delivery_performance.csv
-- Powers: Grouped bar — On-time vs. late delivery rate
-- ============================================================

SELECT
    order_year_month,
    delivery_status,
    COUNT(DISTINCT order_id)            AS order_count,
    ROUND(AVG(delivery_delay_days), 1)  AS avg_delay_days,
    ROUND(AVG(review_score), 2)         AS avg_review_score
FROM vw_clean_orders
GROUP BY order_year_month, delivery_status
ORDER BY order_year_month, delivery_status;

-- ============================================================
-- EXPORT 6: full_order_detail.csv  (for Tableau filters)
-- Main flat table for Tableau — connect this as primary source
-- ============================================================

SELECT
    order_id,
    customer_id,
    customer_unique_id,
    customer_state,
    customer_city,
    category_english,
    payment_type,
    payment_installments,
    payment_value,
    price,
    freight_value,
    review_score,
    delivery_status,
    delivery_delay_days,
    order_year,
    order_month,
    order_quarter,
    order_year_month,
    order_day_of_week,
    seller_state
FROM vw_clean_orders;
