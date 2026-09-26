# E-commerce company: SQL Case Study
TODO:
## Dataset
TODO:
```mermaid
erDiagram
    customers ||--o{ orders : customer_id
    orders ||--o{ OrderDetails : order_id
    products ||--o{ OrderDetails : "product_id"

    customers {
        int customer_id PK
        text name
        text location
    }
    products {
        int product_id PK
        text name
        text category
        int price
    }
    orders {
        int order_id PK
        text order_date
        int customer_id FK
        int total_amount
    }
    OrderDetails {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        int price_per_unit
    }
```

## Project structure

```
├── data/       # raw csv files
├── schema/     # raw create table statements (documentation only)
├── queries/    # one .sql file per task
└── README.md
```

Tool: MySQL 8 (Workbench).

## Tasks

### 1. Describe the tables

**Problem:** Get the structure (columns, types, constraints) of all four tables.

**Approach:** Ran `desc` on each of the four tables.

**Table structures:**

`customers`

| Field | Type | Null | Key | Extra |
|---|---|---|---|---|
| customer_id | int | NO | PRI | |
| name | text | YES | | |
| location | text | YES | | |

`products`

| Field | Type | Null | Key | Extra |
|---|---|---|---|---|
| product_id | int | NO | PRI | |
| name | text | YES | | |
| category | text | YES | | |
| price | int | YES | | |

`orders`

| Field | Type | Null | Key | Extra |
|---|---|---|---|---|
| order_id | int | NO | PRI | |
| order_date | text | YES | | |
| customer_id | int | YES | MUL | |
| total_amount | int | YES | | |

`OrderDetails`

| Field | Type | Null | Key | Extra |
|---|---|---|---|---|
| id | int | NO | PRI | auto_increment |
| order_id | int | YES | MUL | |
| product_id | int | YES | MUL | |
| quantity | int | YES | | |
| price_per_unit | int | YES | | |

**Result:** All four tables confirmed with their expected columns and types, with primary and foreign keys in place across `customer_id`, `product_id`, `order_id`, and the `OrderDetails` surrogate key.

Full query: [queries/01_describe_tables.sql](queries/01_describe_tables.sql)

### 2. Market segmentation analysis: top 3 cities by customer count

**Problem:** Identify the top 3 cities with the highest number of customers, to determine key markets for targeted marketing and logistics optimization.

**Approach:** Grouped `customers` by `location`, counted customers per city, sorted descending, and limited to the top 3.



| location | number_of_customers |
|---|---|
| Delhi | 16 |
| Chennai | 15 |
| Jaipur | 11 |

**Result:** Delhi leads with 16 customers, followed closely by Chennai (15) and Jaipur (11).

Full query: [queries/02_top_cities_by_customers.sql](queries/02_top_cities_by_customers.sql)

### 3. Customer engagement distribution

**Problem:** Determine how many customers fall into each order-frequency category, based on the number of orders they've placed.

**Approach:** Used a CTE to count orders placed per customer (joining `customers` and `orders` on `customer_id`), then grouped that result by order count to get the number of customers per frequency bucket, sorted ascending.

| num_of_orders | CustomerCount |
|---|---|
| 1 | 26 |
| 2 | 26 |
| 3 | 18 |
| 4 | 6 |
| 5 | 6 |
| 6 | 1 |
| 8 | 1 |

**Result:** Most customers (52) placed either 1 or 2 orders, with counts dropping off sharply beyond 3, only one customer each reached 6 and 8 orders, with no customers at 7.

Full query: [queries/03_customer_engagement_distribution.sql](queries/03_customer_engagement_distribution.sql)

### 4. Premium product trends: average quantity per order vs. revenue

**Problem:** Analyze the relationship between average purchase quantity per order and total revenue across all products, to identify which products show premium purchasing trends.

**Approach:** Grouped `OrderDetails` by `product_id`, computing average quantity per order (rounded to 2 decimal places) and total revenue (`price_per_unit * quantity`), sorted by average quantity descending, with total revenue as a tiebreaker.

**Average quantity vs. revenue by product:**

| product_id | AvgQuantity | TotalRevenue |
|---|---|---|
| 6 | 2.27 | 938000 |
| 1 | 2.00 | 1620000 |
| 8 | 2.00 | 390000 |
| 3 | 1.99 | 1080000 |
| 5 | 1.98 | 595000 |
| 7 | 1.94 | 6040000 |
| 4 | 1.91 | 1560000 |
| 2 | 1.88 | 7560000 |

**Result:** No clear correlation between average order quantity and revenue, product 2 has the lowest average quantity (1.88) but the highest total revenue by far (7,560,000), while product 6 has the highest average quantity (2.27) but only mid-range revenue. Products 1 and 8 both average exactly 2.00, and the revenue tiebreaker separates them (1,620,000 vs. 390,000). High-revenue products tend to sell in smaller quantities per order rather than bulk, suggesting price point drives revenue more than purchase volume.

Full query: [queries/04_avg_quantity_per_order_vs_revenue.sql](queries/04_avg_quantity_per_order_vs_revenue.sql)

### 5. Category reach: unique customers per product category

**Problem:** For each product category, calculate the unique number of customers purchasing from it, to understand which categories have the widest appeal across the customer base.

**Approach:** Joined `OrderDetails` to `products` (for category) and `orders` (for customer_id), then counted distinct customers per category, sorted descending.

**Unique customers by category:**

| category | unique_customers |
|---|---|
| Electronics | 79 |
| Wearable Tech | 61 |
| Photography | 45 |

**Result:** Electronics reaches the widest customer base (79 unique customers), followed by Wearable Tech (61) and Photography (45), a fairly steep drop-off between the top and bottom categories, suggesting Electronics is the store's core traffic driver.

Full query: [queries/05_unique_customers_by_category.sql](queries/05_unique_customers_by_category.sql)

### 6. Month-over-month sales growth trend

**Problem:** Analyze the month-on-month percentage change in total sales to identify growth trends, with percent change rounded to 2 decimal places.

**Approach:** Used a subquery to get total sales per month (`date_format(order_date, "%Y-%m")`), with `lag()` fetching the previous month's total in the same pass. The outer query then computes percent change as `(current - previous) / previous * 100`.

**Monthly sales and percent change:**

| Month | TotalSales | PercentChange |
|---|---|---|
| 2023-03 | 789000 | NULL |
| 2023-04 | 1704000 | 115.97 |
| 2023-05 | 1582000 | -7.16 |
| 2023-06 | 1040000 | -34.26 |
| 2023-07 | 2568000 | 146.92 |
| 2023-08 | 1800000 | -29.91 |
| 2023-09 | 2927000 | 62.61 |
| 2023-10 | 1497000 | -48.86 |
| 2023-11 | 1151000 | -23.11 |
| 2023-12 | 2774000 | 141.01 |
| 2024-01 | 1555000 | -43.94 |
| 2024-02 | 396000 | -74.53 |

**Result:** Sales are highly volatile month-to-month, swinging between -74.53% and +146.92% with no sustained upward or downward trend. March 2023 shows NULL because it's the first month with no month before it to compare against.

Full query: [queries/06_month_over_month_sales_growth.sql](queries/06_month_over_month_sales_growth.sql)

### 7. Average order value trend

**Problem:** Examine how the average order value changes month-on-month, to guide pricing and promotional strategies.

**Approach:** Used a CTE to compute the average order value per month (rounded to 2 decimals), with `lag()` fetching the previous month's value in the same pass. The outer query computes the change (current minus previous) and sorts by that change descending.

**Average order value and change by month:**

| Month | AvgOrderValue | ChangeInValue |
|---|---|---|
| 2023-12 | 132095.24 | 36178.57 |
| 2023-04 | 81142.86 | 20450.55 |
| 2023-06 | 104000.00 | 16111.11 |
| 2023-08 | 112500.00 | 13730.77 |
| 2023-11 | 95916.67 | 12750.00 |
| 2023-09 | 121958.33 | 9458.33 |
| 2023-05 | 87888.89 | 6746.03 |
| 2024-01 | 129583.33 | -2511.91 |
| 2023-07 | 98769.23 | -5230.77 |
| 2023-10 | 83166.67 | -38791.66 |
| 2024-02 | 44000.00 | -85583.33 |
| 2023-03 | 60692.31 | NULL |

**Result:** December 2023 saw the largest jump in average order value (+36,178.57), while February 2024 had the biggest drop (-85,583.33), swings of this size suggest order values are being pulled around by a handful of large orders per month rather than a steady trend. March 2023 shows NULL since it's the first month with no prior month to compare against.

Full query: [queries/07_avg_order_value_trend.sql](queries/07_avg_order_value_trend.sql)

### 8. Fast-turnover products: top 5 by sales frequency

**Problem:** Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

**Approach:** Counted order-detail occurrences per product in `orderdetails`, grouped by `product_id`, sorted descending, limited to the top 5.

**Top 5 products by sales frequency:**

| product_id | SalesFrequency |
|---|---|
| 7 | 78 |
| 3 | 68 |
| 4 | 68 |
| 2 | 67 |
| 8 | 65 |

**Result:** Product 7 leads with 78 order-line appearances, notably ahead of the next tier (products 3 and 4, tied at 68), indicating it's the standout candidate for frequent restocking priority.

Full query: [queries/08_fast_turnover_products.sql](queries/08_fast_turnover_products.sql)

## How to run

Requires MySQL 8+ and MySQL Workbench.

1. **Create the database:**
    ```sql
    create database e_commerce_company;
    ```
2. **Import the csv files** from [data/](data/). In Workbench, right-click `e_commerce_company` -> `Table Data Import Wizard`, pick a csv, and choose `Create new table`. Repeat for each of the four files. Keep the date columns (`order_date`) as text.

TODO: do they depend on order AND INVOLVE CLEANING?

3. **Run the files in [queries/](queries/) in order** (`01_...`, `02_...`, and so on). Later queries depend on the cleaning done by earlier ones, so don't skip or reorder them.

[schema/schema.sql](schema/schema.sql) documents the raw tables as they look right after import. You don't need to run it.

To start over, drop the database and repeat from step 1.