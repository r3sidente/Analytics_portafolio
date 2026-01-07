# SQL Operational Analytics Portfolio

This project demonstrates an end-to-end SQL analytics workflow focused on **operational performance**, **data quality**, **KPIs**, and **time-based trends**, using a realistic logistics-style dataset built in SQLite.

The goal of the project is not only to calculate metrics, but to show **analytical thinking**, **data validation**, and **decision-oriented insights**, similar to what is expected in real operational analytics roles.

---

## 🧱 Data Model

### Orders
Represents customer orders and delivery performance.

**Table:** `orders`
- `order_id` (PK)
- `order_date`
- `promised_date`
- `delivered_date`
- `status`

---

### Operations
Represents operational handling per order (aggregated at order level).

**Table:** `operations`
- `ops_id` (PK)
- `order_id` (FK → orders.order_id)
- `warehouse`
- `proces_time_hours`
- `delay_reasons`

> Note: Column names intentionally match the original schema, including typos, to reflect real-world data constraints.

---

## 📁 Repository Structure

---

## 1. Data Quality Checks

Before any analysis, the dataset is validated using explicit **data quality and integrity checks**.

Implemented in:  
`queries/01_quality_checks.sql`

These checks ensure:
- Valid and coherent order dates
- No impossible delivery timelines
- Referential integrity between orders and operations
- Valid operational process times
- Logical consistency between delivery delays and delay reasons

This step reflects real-world analytics workflows, where unreliable data invalidates any downstream analysis.

---

## 2. Core KPIs

Core KPIs provide a **point-in-time view of operational performance**.

Implemented in:  
`queries/02_kpis.sql`

Key metrics include:
- Order completion rate
- On-time delivery percentage
- Delivery delay statistics
- Order cycle time (order to delivery)
- Average operational process time
- Warehouse-level performance
- Delay distribution and delay rate by warehouse

These KPIs answer the question:  
**“How is the operation performing right now?”**

---

## 3. Trends Analysis

Trends extend KPIs by analyzing how performance evolves **over time**.

Implemented in:  
`queries/03_trends.sql`

The trends analysis focuses on:
- Monthly order volume and backlog evolution
- On-time delivery performance over time
- Cycle time trends
- Operational efficiency trends
- Warehouse performance comparison over time
- Delay reasons and delay rates by warehouse and month

Trends answer the question:  
**“Is the operation improving, degrading, or remaining unstable?”**

They help identify seasonality, bottlenecks, and site-specific operational risks.

---

## Analytical Approach

This project follows a structured analytics mindset:

1. Validate data before analysis  
2. Measure current performance using KPIs  
3. Analyze trends to understand changes over time  
4. Enable operational decision-making, not just reporting  

The focus is on clarity, correctness, and business relevance.

---

## Technology

- Database: SQLite  
- Language: SQL  
- Concepts:
  - Data quality validation
  - Operational KPIs
  - Time-series trend analysis
  - Warehouse performance analysis

---

## Author

This project was built as part of a professional analytics portfolio, showcasing SQL skills applied to realistic operational scenarios.


