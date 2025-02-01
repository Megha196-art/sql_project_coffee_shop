# Monday Coffee Expansion SQL Project

![image](https://github.com/user-attachments/assets/12656a89-8653-412f-b939-a94c84fe6900)

## Project Overview

**Project Title**: Coffee Shop Business Expansion 
**Level**: Advanced  
**Database**: `business_exp_sql_project`

## Objective
The business aims to expand by opening three coffee shops in India's top three major cities. Since its launch in January 2023, the company has successfully sold its products online and received an overwhelmingly positive response in several cities. As a data analyst, your task is to analyze the sales data and provide insights to recommend the top three cities for this expansion.

## Key Questions
1. **Coffee Consumers Count**  
   How many people in each city are estimated to consume coffee, given that 25% of the population does?

```sql
SELECT
      city_id,
      city_name,
      ROUND((population * 0.25)/1000000, 2) as coffee_cust_in_millions,
      city_rank
FROM city
ORDER BY coffee_cust_in_millions DESC;  
```
The top 5 cities with the highest number of coffee consumers are Delhi, Mumbai, Kolkata, Bangalore, Chennai


2. **Total Revenue from Coffee Sales**  
   What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

```sql
SELECT 
       city_name,
       SUM(total_sale) as total_revenue
FROM sales
INNER JOIN customers
ON sales.customer_id = customers.customer_id
INNER JOIN city
ON customers.city_id = city.city_id
WHERE sales.sale_date BETWEEN '2023-09-01' AND '2023-12-31'
GROUP BY city_name
ORDER BY total_revenue DESC;  
```
For the last quarter of 2023, the top 5 cities that had the highest revenue generated are Pune, Chennai, Bangalore, Jaipur, Delhi


3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold?

```sql
SELECT 
      p.product_name,
      COUNT(sale_id) as product_total_sales
FROM products as p
LEFT JOIN sales as s
ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY product_total_sales DESC;  
```
When selecting products for a coffee shop, it's important to consider both popular coffee-related items and high-performing non-coffee products. Among coffee offerings, brewed coffee packs had the highest sales, followed by ground espresso, instant coffee powder, and coffee beans. Additionally, non-coffee items like the "tote bag with coffee design" also saw significant demand. This indicates an opportunity to diversify the product range, combining core coffee products with complementary merchandise to maximize sales and attract a wider customer base.

4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city?

```sql
SELECT 
       ci.city_name,
       SUM(s.total_sale) as total_revenue,
       COUNT(DISTINCT s.customer_id) as total_customers,
       ROUND(SUM(s.total_sale)/COUNT(DISTINCT s.customer_id), 2) as avg_sale_per_cust
FROM sales as s
INNER JOIN customers as c
ON s.customer_id = c.customer_id
INNER JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY city_name
ORDER BY total_revenue DESC;  
```
The 5 highest avg sales per customer can be seen in Pune, Chennai, Banaglore, Jaipur and Delhi

5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers.

```sql
WITH city_table 
AS
(
  SELECT
      city_name,
      ROUND((population * 0.25)/1000000, 2) as est_cx_in_millions
  FROM city
),
customers_table
AS
(
SELECT
      ci.city_name,
      COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
JOIN customers as c
ON ci.city_id = c.city_id
JOIN sales as s
ON c.customer_id = s.customer_id
GROUP BY ci.city_name
)

SELECT
      city_table.city_name,
      city_table.est_cx_in_millions,
      customers_table.unique_cx
FROM city_table 
JOIN customers_table 
ON city_table.city_name = customers_table.city_name
ORDER BY unique_cx DESC;  
```
In terms of unique customers Jaipur, Delhi, Pune, Chennai and Bangalore have the highest no. of unique customers

6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume?

```sql
SELECT * 
FROM
(
SELECT 
      ci.city_name,
      p.product_name,
      COUNT(s.sale_id) as total_orders,
      DENSE_RANK() OVER(PARTITION BY  ci.city_name ORDER BY COUNT(s.sale_id) DESC) as ranking
FROM products as p
JOIN sales as s
ON p.product_id = s.product_id
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name, p.product_name
) as t1
WHERE ranking <= 3; 
```
Top 3 Selling Coffee Products by City

| City       | 1st Best-Selling Product                 | 2nd Best-Selling Product                 | 3rd Best-Selling Product                 |
|------------|---------------------------------|---------------------------------|---------------------------------|
| Ahmedabad  | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             | Instant Coffee Powder (100g)    |
| Bangalore  | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Instant Coffee Powder (100g)    |
| Chennai    | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             | Instant Coffee Powder (100g)    |
| Delhi      | Ground Espresso Coffee (250g)     | Instant Coffee Powder (100g)    | Coffee Beans (500g)             |
| Hyderabad  | Instant Coffee Powder (100g)      | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   |
| Indore     | Instant Coffee Powder (100g)      | Ground Espresso Coffee (250g)   | Cold Brew Coffee Pack (6 Bottles) |
| Jaipur     | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             | Instant Coffee Powder (100g)    |
| Kanpur     | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Coffee Beans (500g)             |
| Kolkata    | Ground Espresso Coffee (250g)     | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             |
| Lucknow    | Instant Coffee Powder (100g)      | Coffee Beans (500g)             | Cold Brew Coffee Pack (6 Bottles) |
| Mumbai     | Ground Espresso Coffee (250g)     | Instant Coffee Powder (100g)    | Cold Brew Coffee Pack (6 Bottles) |
| Nagpur     | Ground Espresso Coffee (250g)     | Instant Coffee Powder (100g)    | Coffee Beans (500g)             |
| Pune       | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Instant Coffee Powder (100g)    |
| Surat      | Coffee Beans (500g)               | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   |


**Key Insights:**
1. Cold Brew Coffee Pack (6 Bottles) emerged as the best-selling product in most cities.
2. Ground Espresso Coffee (250g) consistently ranked as the second most popular product.
3. Instant Coffee Powder (100g) was the third highest-selling product across multiple locations.
4. Coffee Beans (500g) also performed well in several cities, particularly Ahmedabad, Chennai, Jaipur, and Surat.
   
This data suggests that Cold Brew Coffee Packs, Ground Espresso, and Instant Coffee Powder should be prioritized when curating a product lineup for a coffee shop.

8. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?

9. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer

10. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

11. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer
    

## Recommendations
After analyzing the data, the recommended top three cities for new store openings are:

**City 1: Pune**  
1. Average rent per customer is very low.  
2. Highest total revenue.  
3. Average sales per customer is also high.

**City 2: Delhi**  
1. Highest estimated coffee consumers at 7.7 million.  
2. Highest total number of customers, which is 68.  
3. Average rent per customer is 330 (still under 500).

**City 3: Jaipur**  
1. Highest number of customers, which is 69.  
2. Average rent per customer is very low at 156.  
3. Average sales per customer is better at 11.6k.

---
