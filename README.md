# E-commerce Company SQL Analysis

SQL analysis of an e-commerce company's customers, products and orders, written in MySQL. It answers 11 business questions on customer behaviour, product performance, sales trends and inventory, using joins, CTEs and window functions.

## Objectives

- **Customer insights:** find the biggest city markets, how often customers order, and how fast new customers are being acquired
- **Product performance:** compare average order quantity with revenue and see which categories reach the most customers
- **Sales trends:** track month-over-month sales growth and average order value, and find peak months
- **Inventory planning:** spot fast-turnover products and products with low customer adoption
## Dataset
The dataset covers an e-commerce company's customers, products and orders, with orders placed between March 2023 and February 2024. The raw csv files are included in this repo under [data/](data/).

| Table | Rows | Contents |
|---|---|---|
| `customers` | 100 | customer id, name and city |
| `products` | 8 | product id, name, category and price |
| `orders` | 200 | order id, order date, customer and total amount |
| `orderdetails` | 519 | the products in each order: product, quantity and price per unit |

Every table has a primary key, and `orders` and `orderdetails` link to their parent tables through foreign keys, as the diagram below shows. `orderdetails` has no natural primary key because an order can list the same product on more than one line, so it gets a surrogate `id`. The keys are added by [schema/schema.sql](schema/schema.sql) after import.
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

**Approach:** Used left-join on `OrderDetails` and `Products` (for product name), then grouped by `product_id`, computing average quantity per order (rounded to 2 decimal places) and total revenue (`price_per_unit * quantity`), sorted by average quantity descending, with total revenue as a tiebreaker.

**Average quantity vs. revenue by product:**

| product_id | name | AvgQuantity | TotalRevenue |
|---|---|---|---|
| 6 | Portable Bluetooth Speaker | 2.27 | 938000 |
| 1 | Smartphone 6" | 2.00 | 1620000 |
| 8 | Wireless Earbuds | 2.00 | 390000 |
| 3 | Bluetooth Headphones | 1.99 | 1080000 |
| 5 | Smartwatch Fitness Tracker | 1.98 | 595000 |
| 7 | Digital SLR Camera | 1.94 | 6040000 |
| 4 | E-Book Reader | 1.91 | 1560000 |
| 2 | Laptop 15" Pro | 1.88 | 7560000 |

**Result:** No clear correlation between average order quantity and revenue, product 2 (Laptop 15" Pro) has the lowest average quantity (1.88) but the highest total revenue by far (7,560,000), while product 6 (Portable Bluetooth Speaker) has the highest average quantity (2.27) but only mid-range revenue. Products 1 (Smartphone 6") and 8 (Wireless Earbuds) both average exactly 2.00, and the revenue tiebreaker separates them (1,620,000 vs. 390,000). High-revenue products tend to sell in smaller quantities per order rather than bulk, suggesting price point drives revenue more than purchase volume.

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

| product_id | name | SalesFrequency |
|---|---|---|
| 7 | Digital SLR Camera | 78 |
| 3 | Bluetooth Headphones | 68 |
| 4 | E-Book Reader | 68 |
| 2 | Laptop 15" Pro | 67 |
| 8 | Wireless Earbuds | 65 |

**Result:** Product 7 (Digital SLR Camera) leads with 78 order-line appearances, notably ahead of the next tier ('Bluetooth Headphones' and 'E-Book Reader', tied at 68), indicating it's the standout candidate for frequent restocking priority.

Full query: [queries/08_fast_turnover_products.sql](queries/08_fast_turnover_products.sql)

### 9. Inventory-interest mismatch: low-adoption products

**Problem:** List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

**Approach:** Listed all products first for context. Then joined `orderdetails` -> `products` -> `orders` -> `customers`, counted distinct customers per product, and filtered (via `having`) to products where that count is below 40% of the total customer count (computed with a subquery instead of hardcoding).

**All products:**

| product_id | name | category | price |
|---|---|---|---|
| 1 | Smartphone 6" | Electronics | 15000 |
| 2 | Laptop 15" Pro | Electronics | 60000 |
| 3 | Bluetooth Headphones | Electronics | 8000 |
| 4 | E-Book Reader | Electronics | 12000 |
| 5 | Smartwatch Fitness Tracker | Wearable Tech | 5000 |
| 6 | Portable Bluetooth Speaker | Electronics | 7000 |
| 7 | Digital SLR Camera | Photography | 40000 |
| 8 | Wireless Earbuds | Wearable Tech | 3000 |

**Products below the 40% customer-adoption threshold:**

| product_id | name | UniqueCustomerCount |
|---|---|---|
| 1 | Smartphone 6" | 36 |
| 8 | Wireless Earbuds | 38 |

**Result:** 6 of the 8 total products meet or exceed the 40% customer-adoption threshold, only Smartphone 6" (36) and Wireless Earbuds (38) fall short, making them the clearest candidates for inventory or marketing review.

Full query: [queries/09_low_adoption_products.sql](queries/09_low_adoption_products.sql)

### 10. Customer acquisition: new customers by month

**Problem:** Evaluate the month-on-month growth in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

**Approach:** Used a CTE to find each customer's first purchase month (min `order_date` per customer, formatted as `YYYY-MM`), then grouped by `FirstPurchaseMonth` in the main query to count how many customers made their first purchase in each month, sorted ascending.

**New customers by first purchase month:**

| FirstPurchaseMonth | TotalNewCustomers |
|---|---|
| 2023-03 | 11 |
| 2023-04 | 18 |
| 2023-05 | 11 |
| 2023-06 | 8 |
| 2023-07 | 11 |
| 2023-08 | 9 |
| 2023-09 | 5 |
| 2023-10 | 3 |
| 2023-11 | 1 |
| 2023-12 | 4 |
| 2024-01 | 2 |
| 2024-02 | 1 |

**Result:** New-customer acquisition peaked early, with April 2023 bringing the most first-time buyers (18), and then it fell off, with 4 or less new customers in any month from October 2023 onward.

Full query: [queries/10_new_customers_by_month.sql](queries/10_new_customers_by_month.sql)

### 11. Peak sales months: top 3 by total sales

**Problem:** Identify the months with the highest sales volume, to help plan stock levels, marketing efforts, and staffing ahead of peak demand periods.

**Approach:** Grouped `orders` by month (`YYYY-MM`), summed `total_amount` for each, sorted descending, and limited to the top 3.

**Top 3 months by total sales:**

| Month | TotalSales |
|---|---|
| 2023-09 | 2927000 |
| 2023-12 | 2774000 |
| 2023-07 | 2568000 |

**Result:** September 2023 was the strongest month (2,927,000), followed by December 2023 (2,774,000) and July 2023 (2,568,000). The three peaks are spread across the year rather than clustered in one stretch.

Full query: [queries/11_peak_sales_months.sql](queries/11_peak_sales_months.sql)

## How to run

Requires MySQL 8+ and MySQL Workbench.

1. **Create the database:**
    ```sql
    create database e_commerce_company;
    ```
2. **Import the csv files** from [data/](data/). In Workbench, right-click `e_commerce_company` -> `Table Data Import Wizard`, pick a csv, and choose `Create new table`. Repeat for each of the four files. Name the tables `Customers`, `Products`, `Orders` and `OrderDetails`.
3. **Add primary and foreign keys.** The import wizard doesn't create them, so run the `alter table` statements from [schema/schema.sql](schema/schema.sql) once, in the order given.
4. **Run any file in [queries/](queries/).** Each one is a standalone, read-only query, so they can be run in any order.

[schema/schema.sql](schema/schema.sql) holds the full table definitions plus the key setup. After importing through the wizard, only its `alter table` statements need running; the `create table` statements above them are there for reference.

To start over, drop the database and repeat from step 1.

## Key Findings

- **Electronics reaches the most customers.** 79 unique customers bought from it ([Task 5](#5-category-reach-unique-customers-per-product-category)), against 61 for Wearable Tech and 45 for Photography, though it also holds 5 of the 8 products ([Task 9](#9-inventory-interest-mismatch-low-adoption-products)).
- **Price appears to drive revenue more than order quantity.** The Laptop 15" Pro (product 2) has the lowest average quantity per order (1.88) but the highest total revenue (7,560,000) ([Task 4](#4-premium-product-trends-average-quantity-per-order-vs-revenue)).
- **Monthly sales are volatile with no clear trend.** Month-over-month change runs from -74.53% to +146.92% ([Task 6](#6-month-over-month-sales-growth-trend)), and September, December and July 2023 were the top three months by total sales ([Task 11](#11-peak-sales-months-top-3-by-total-sales)).
- **New first-time buyers peaked in April 2023** [Task 10](#10-customer-acquisition-new-customers-by-month) shows 18 new customers in April 2023 and 4 or fewer per month from October 2023, though the customer list is fixed, so a falling count is partly expected as more customers have already placed a first order.
- **Fast turnover and low adoption can overlap.** The Digital SLR Camera (product 7) appears in the most order lines, 78 ([Task 8](#8-fast-turnover-products-top-5-by-sales-frequency)). Wireless Earbuds make the top 5 by order lines (65, [Task 8](#8-fast-turnover-products-top-5-by-sales-frequency)) yet fall below the 40% adoption threshold with 38 customers, as does Smartphone 6" with 36 ([Task 9](#9-inventory-interest-mismatch-low-adoption-products)).