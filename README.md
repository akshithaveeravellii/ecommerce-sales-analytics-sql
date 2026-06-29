# E-Commerce Sales & KPI Analytics Dashboard
### SQL + Tableau | Data Analyst Portfolio Project

---

## Project Overview

This project analyzes **100,000+ real orders** from Olist, Brazil's largest e-commerce marketplace (2016–2018). Using SQL for data extraction and transformation and Tableau for visualization, I built an end-to-end analytics pipeline that answers critical business questions about revenue, customer behavior, product performance, and delivery efficiency.

**Role this project targets:** Data Analyst  
**Tools used:** MySQL · Tableau Public · CSV (Kaggle dataset)  
**Dataset:** [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)


---

## Key Findings

- Total revenue across 2016–2018: **~$16M BRL**
- MoM revenue grew consistently, peaking in **Q1 2018**
- **Bed, Bath & Table** is the highest-volume category; **Computers** has the highest average order value
- **São Paulo** accounts for ~40% of all orders — far ahead of any other state
- **Credit card** is used in 74% of transactions, with most customers choosing 1–3 installments
- Late deliveries correlate with a **0.8 point drop** in average review score (3.9 vs 4.7)

---

## SQL Skills Demonstrated

| Concept | Where Used |
|---|---|
| Multi-table JOINs (5 tables) | `vw_clean_orders` view in `02_data_cleaning.sql` |
| Window functions — LAG() | MoM revenue growth in `03_kpi_analysis.sql` |
| Window functions — RANK(), SUM() OVER() | Category ranking with running total |
| CTEs | Monthly trend query |
| CASE WHEN | Delivery status, delivery delay classification |
| Conditional aggregation | On-time delivery % |
| Date functions | Year/month/quarter extraction |
| CREATE VIEW | Reusable clean data layer |
| NULL handling | COALESCE for missing categories, NULLIF for division safety |
| Aggregate functions | Revenue, AOV, order count KPIs |

---

## Project Structure

```
ecommerce-sales-analytics-sql/
├── sql/
│   ├── 01_setup_and_load.sql      — Create tables, load CSVs
│   ├── 02_data_cleaning.sql       — Inspect quality, build clean view
│   ├── 03_kpi_analysis.sql        — All 10 KPI queries
│   └── 04_tableau_exports.sql     — Queries to export CSVs for Tableau
├── docs/
│   └── tableau_guide.md           — Step-by-step Tableau dashboard build
└── README.md
```

---

## Tableau Dashboard

> **[View Live Dashboard on Tableau Public →](#)**  
> *(Replace this link with your published Tableau Public URL after uploading)*

Dashboard includes:
- Monthly revenue trend line chart with MoM growth labels
- Top 10 product categories horizontal bar chart
- Revenue by state filled map
- Payment method pie chart
- Delivery performance grouped bar
- 4 KPI summary cards at the top


---

## Connect

**LinkedIn:** https://www.linkedin.com/in/a-veeravelli/
