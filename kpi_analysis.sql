-- ============================================================
-- PROJECT 1: E-Commerce Sales & KPI Analytics
-- FILE 03: KPI Analysis (all queries power the Tableau dashboard)
-- ============================================================

-- ============================================================
-- KPI 1: Overall Business Summary
-- ============================================================

SELECT
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(DISTINCT customer_id)             AS total_customers,
    ROUND(SUM(payment_value), 2)            AS total_revenue,
    ROUND(AVG(payment_value), 2)            AS avg_order_value,
    ROUND(SUM(freight_value), 2)            AS total_freight_cost,
    ROUND(AVG(review_score), 2)             AS avg_review_score,
    ROUND(
        SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                       AS on_time_delivery_pct
FROM vw_clean_orders;

-- ============================================================
-- KPI 2: Monthly Revenue Trend (MoM Growth)
-- Key SQL: Window functions — LAG() to compare to prior month
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        order_year_month,
        order_year,
        order_month,
        ROUND(SUM(payment_value), 2)        AS revenue,
        COUNT(DISTINCT order_id)            AS total_orders,
        ROUND(AVG(payment_value), 2)        AS avg_order_value
    FROM vw_clean_orders
    GROUP BY order_year_month, order_year, order_month
)
SELECT
    order_year_month,
    order_year,
    order_month,
    revenue,
    total_orders,
    avg_order_value,
    LAG(revenue) OVER (ORDER BY order_year_month)   AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year_month))
        * 100.0 / NULLIF(LAG(revenue) OVER (ORDER BY order_year_month), 0),
    2)                                              AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_year_month;

-- ============================================================
-- KPI 3: Quarterly Revenue Summary (for Tableau bar chart)
-- ============================================================

SELECT
    order_year,
    order_quarter,
    CONCAT('Q', order_quarter, ' ', order_year)     AS quarter_label,
    ROUND(SUM(payment_value), 2)                    AS quarterly_revenue,
    COUNT(DISTINCT order_id)                        AS quarterly_orders,
    ROUND(AVG(payment_value), 2)                    AS quarterly_aov
FROM vw_clean_orders
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;

-- ============================================================
-- KPI 4: Top 10 Product Categories by Revenue and Orders
-- ============================================================

SELECT
    category_english,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_value), 2)        AS avg_order_value,
    ROUND(AVG(review_score), 2)         AS avg_review_score,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0
        / (SELECT COUNT(DISTINCT order_id) FROM vw_clean_orders),
    2)                                  AS pct_of_total_orders
FROM vw_clean_orders
GROUP BY category_english
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- KPI 5: Revenue and Orders by Customer State (for map viz)
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_id)         AS unique_customers,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_value), 2)        AS avg_order_value
FROM vw_clean_orders
GROUP BY customer_state
ORDER BY total_revenue DESC;

-- ============================================================
-- KPI 6: Payment Method Breakdown
-- ============================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_installments), 1) AS avg_installments,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0
        / (SELECT COUNT(DISTINCT order_id) FROM vw_clean_orders),
    2)                                  AS pct_of_orders
FROM vw_clean_orders
GROUP BY payment_type
ORDER BY total_orders DESC;

-- ============================================================
-- KPI 7: Order Delivery Performance
-- ============================================================

SELECT
    delivery_status,
    COUNT(DISTINCT order_id)            AS order_count,
    ROUND(AVG(delivery_delay_days), 1)  AS avg_delay_days,
    ROUND(AVG(review_score), 2)         AS avg_review_score,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0
        / (SELECT COUNT(DISTINCT order_id) FROM vw_clean_orders),
    2)                                  AS pct_of_total
FROM vw_clean_orders
GROUP BY delivery_status;

-- ============================================================
-- KPI 8: Day of Week Order Patterns
-- ============================================================

SELECT
    order_day_of_week,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(payment_value), 2)        AS avg_order_value
FROM vw_clean_orders
GROUP BY order_day_of_week
ORDER BY FIELD(order_day_of_week,
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- ============================================================
-- KPI 9: Top 10 Sellers by Revenue
-- ============================================================

SELECT
    seller_id,
    seller_state,
    seller_city,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_revenue,
    ROUND(AVG(review_score), 2)         AS avg_review_score
FROM vw_clean_orders
GROUP BY seller_id, seller_state, seller_city
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================================
-- KPI 10: Revenue Ranking by Category with Running Total
-- Key SQL: RANK() and SUM() OVER() window functions
-- ============================================================

SELECT
    category_english,
    ROUND(SUM(payment_value), 2)        AS category_revenue,
    RANK() OVER (ORDER BY SUM(payment_value) DESC)
                                        AS revenue_rank,
    ROUND(
        SUM(SUM(payment_value)) OVER (ORDER BY SUM(payment_value) DESC),
    2)                                  AS running_total_revenue,
    ROUND(
        SUM(payment_value) * 100.0
        / SUM(SUM(payment_value)) OVER (),
    2)                                  AS pct_of_total_revenue
FROM vw_clean_orders
GROUP BY category_english
ORDER BY revenue_rank;
