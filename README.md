# Monday Coffee Expansion SQL Project

![image](https://github.com/user-attachments/assets/12656a89-8653-412f-b939-a94c84fe6900)

## Project Overview

**Project Title**: Coffee Shop Business Expansion 
**Level**: Advanced  
**Database**: `business_exp_sql_project`

## Objective
The business aims to expand by opening three coffee shops in India's top three major cities. Since its launch in January 2023, the company has successfully sold its products online and received an overwhelmingly positive response in several cities. As a data analyst, your task is to analyze the sales data and provide insights to recommend the top three cities for this expansion.

## Key Questions
Q1. **Coffee Consumers Count**  
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


Q2. **Total Revenue from Coffee Sales**  
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


Q3. **Sales Count for Each Product**  
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

Q4. **Average Sales Amount per City**  
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

Q5. **City Population and Coffee Consumers**  
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

Q6. **Top Selling Products by City**  
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
Top 3 Selling Coffee Products by City:

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


Q7. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?

```sql
SELECT *
FROM
(
SELECT 
      ci.city_name,
      p.product_name,
      p.product_id,
      COUNT(DISTINCT c.customer_id) as unique_cx,
      DENSE_RANK () OVER(PARTITION BY ci.city_name ORDER BY COUNT(DISTINCT c.customer_id) DESC) as ranking
FROM customers as c 
JOIN city as ci
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
JOIN products as p
ON p.product_id = s.product_id
WHERE 
     p.product_id BETWEEN 1 AND 14
GROUP BY 
        ci.city_name, p.product_name, p.product_id
) as t1
WHERE ranking <= 3;
```
Top 3 coffee products with unique customers across Cities:

| City       | 1st Highest Unique Customers           | 2nd Highest Unique Customers           | 3rd Highest Unique Customers           | Additional Products (if any)            |
|------------|---------------------------------|---------------------------------|---------------------------------|---------------------------------|
| Ahmedabad  | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             | Instant Coffee Powder (100g)    | Ground Espresso Coffee (250g)  |
| Bangalore  | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Instant Coffee Powder (100g)    | Coffee Beans (500g)            |
| Chennai    | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)             | Instant Coffee Powder (100g)    | Ground Espresso Coffee (250g)  |
| Delhi      | Instant Coffee Powder (100g)      | Ground Espresso Coffee (250g)   | Coffee Beans (500g)             | -                              |
| Hyderabad  | Instant Coffee Powder (100g)      | Coffee Beans (500g)             | Cold Brew Coffee Pack (6 Bottles) | -                          |
| Indore     | Coffee Beans (500g)               | Instant Coffee Powder (100g)    | Ground Espresso Coffee (250g)   | Vanilla Coffee Syrup (250ml), Cold Brew Coffee Pack (6 Bottles) |
| Jaipur     | Coffee Beans (500g)               | Instant Coffee Powder (100g)    | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g) |
| Kanpur     | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Coffee Beans (500g)             | -                              |
| Kolkata    | Ground Espresso Coffee (250g)     | Cold Brew Coffee Pack (6 Bottles) | Coffee Beans (500g)           | -                              |
| Lucknow    | Instant Coffee Powder (100g)      | Coffee Beans (500g)             | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g) |
| Mumbai     | Ground Espresso Coffee (250g)     | Instant Coffee Powder (100g)    | Cold Brew Coffee Pack (6 Bottles) | -                              |
| Nagpur     | Ground Espresso Coffee (250g)     | Instant Coffee Powder (100g)    | Coffee Beans (500g)             | Cold Brew Coffee Pack (6 Bottles) |
| Pune       | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g)   | Instant Coffee Powder (100g)    | -                              |
| Surat      | Coffee Beans (500g)               | Cold Brew Coffee Pack (6 Bottles) | Ground Espresso Coffee (250g) | -                              |

**Key Takeaways**
1. Cold Brew Coffee is a clear winner in hotter and urban-centric cities.
2. Instant Coffee Powder is preferred in Delhi, Mumbai, and other fast-paced cities.
3. Coffee Beans & Ground Espresso Coffee are favored in Surat, Indore, Bangalore, indicating a preference for quality home-brewed coffee.
4. Flavored coffee products (like Vanilla Coffee Syrup) could be an emerging trend, particularly in Indore.
   

Q8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer

```sql
WITH city_table
AS
(SELECT 
    ci.city_name,
    SUM(s.total_sale) AS total_sales,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(s.total_sale) / COUNT(DISTINCT c.customer_id),
            2) AS avg_sale_per_customer
FROM
    city AS ci
        JOIN
    customers AS c ON ci.city_id = c.city_id
        JOIN
    sales AS s ON c.customer_id = s.customer_id
GROUP BY ci.city_name
ORDER BY COUNT(DISTINCT c.customer_id) DESC),

city_rent
AS
(SELECT
       city_name,
       estimated_rent
FROM city)

SELECT 
      cr.city_name,
      cr.estimated_rent,
      ct.total_customers,
      ct.avg_sale_per_customer,
      ROUND(cr.estimated_rent/ct.total_customers, 2) as avg_rent_cust
FROM city_table as ct
JOIN city_rent as cr
ON ct.city_name = cr.city_name
ORDER BY 4;
```
**Key Takeaways**

1. High Average Sale & Low Rent – Best City for Expansion

- Pune emerges as the ideal choice for opening a new store.
- It has the highest average sale per customer while maintaining a low rent per customer, making it the most profitable location.

2. High Sales & Low Rent Advantage – Pune, Chennai, and Bangalore

- Pune, Chennai, and Bangalore have the highest average sale per customer.
- The rent per customer in these cities is also relatively low, making them strong contenders for business expansion.

3. Lowest Rent – Jaipur

- Among all cities, Jaipur has the lowest average rent.
- While rent costs are minimal, further analysis of customer sales trends is needed to assess profitability.


Q9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

```sql
WITH 
monthly_sales
AS
(
SELECT 
    ci.city_name,
    MONTH(s.sale_date) AS month,
    YEAR(s.sale_date) AS year,
    SUM(total_sale) AS total_sales
FROM
    sales AS s
        JOIN
    customers AS c ON s.customer_id = c.customer_id
        JOIN
    city AS ci ON c.city_id = ci.city_id
GROUP BY 1, 2, 3
ORDER BY 1, 3, 2
),
growth_ratio
AS
(
SELECT
      city_name,
      month,
      year,
      total_sales as cr_month_sale,
      LAG(total_sales, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
FROM monthly_sales
)

SELECT 
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    ROUND((cr_month_sale - last_month_sale) / last_month_sale * 100,
            2) AS growth_ratio
FROM
    growth_ratio
;
```
**Key Takeaways and Inference**

| City      | 2023 - Highest Growth | 2023 - Highest Decline | 2023 - Highest Sales | 2023 - Lowest Sales | 2024 - Highest Growth | 2024 - Highest Decline | 2024 - Highest Sales | 2024 - Lowest Sales |
|-----------|-----------------------|------------------------|----------------------|---------------------|-----------------------|------------------------|----------------------|---------------------|
| Ahmedabad | Sep (Highest Growth)  | Dec (Steep Decline)    | Nov (21,250)         | -                   | May (32.91%)          | Aug (-71.79%)         | -                    | -                   |
| Bangalore | Sep (130.92%)         | -                      | Nov (106,100)        | -                   | Sep (74.72%)          | Apr (-77.57%)         | Feb (60,650)         | -                   |
| Chennai   | Sep (174.69%)         | Dec (-31.74%)         | Oct (124,650)        | Aug (27,850)        | Jul (60.87%)          | Oct (-98.48%)         | Feb (75,950)         | Oct (350)           |
| Delhi     | Sep (228.65%)         | Aug (-24.97%)         | Dec (85,690)         | Jan (15,680)        | May (Highest Growth)  | Oct (Steep Decline)   | Mar (77,800)         | Oct (900)           |
| Hyderabad | Sep (112.86%)         | -                      | Nov (19,350)         | Jan (2,170)         | Aug (79.17%)          | Apr (-71.60%)         | Mar (12,500)         | Jul (1,200)         |
| Indore    | Jun (27,429%)         | Aug (-46.90%)         | Nov (1,850)          | May (1,750)         | May (125.53%)         | Jun (-80.50%)         | Mar (112,050)        | Aug (1,250)         |
| Jaipur    | Sep (223.21%)         | Jun (-42.34%)         | Dec (93,830)         | Aug (16,800)        | Sep (45.66%)          | Oct (-96.03%)         | Mar (71,100)         | Oct (900)           |
| Kanpur    | Sep (152.50%)         | Dec (-29.22%)         | Nov (28,100)         | Jul (2,320)         | May (254.55%)         | Apr (-81.92%)         | Feb (20,650)         | Sep (2,550)         |
| Kolkata   | Mar (160.78%)         | Dec (-33.02%)         | -                    | -                   | Jun (142.19%)         | Apr (-79.42%)         | Feb (15,950)         | Oct (1,500)         |
| Lucknow   | Aug (190.70%)         | Jan (-67.51%)         | Dec (18,250)         | May (850)           | Aug (81.25%)          | Apr (-78.95%)         | Mar (10,450)         | Sep (1,450)         |
| Mumbai    | Sep (246.67%)         | Jul (-50.89%)         | Nov (26,350)         | Aug (4,500)         | Aug (158.33%)         | Apr (-85.78%)         | Mar (21,450)         | Apr (3,050)         |
| Nagpur    | Sep (208.33%)         | Apr (-49.07%)         | Nov (16,650)         | Jan (2,000)         | Aug (111.43%)         | Apr (-62.85%)         | Feb (12,800)         | Jul (1,750)         |
| Pune      | Sep (217.99%)         | Aug (-48.95%)         | Nov (169,350)        | Aug (27,800)        | May (64.51%)          | Oct (-96.83%)         | Mar (97,150)         | Oct (850)           |
| Surat     | Mar (323.13%)         | Feb (-66.32%)         | Nov (18,250)         | Feb (1,600)         | Feb (46.19%)          | Apr (-57.06%)         | Jan (16,400)         | Sep (2,950)         |



Q10. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer

```sql
SELECT
      ci.city_name, 
      SUM(s.total_sale) as total_sales, 
      SUM(ci.estimated_rent) as total_rent, -- total rent
      COUNT(DISTINCT c.customer_id) as total_customers, -- total customers
      ROUND((ci.population * 0.25)/1000000, 2) as est_coffee_cx_millions, -- ci.population -- estimated coffee consumer
      RANK() OVER(ORDER BY SUM(s.total_sale) DESC) as ranking
FROM city as ci
JOIN customers as c
ON ci.city_id = c.city_id
JOIN sales as s
ON c.customer_id = s.customer_id
GROUP BY 1,5;
```
**tTop three citites in terms of total sales**
-- 1. Pune      total sales = (1258290) and total customers = 52
-- 2. Chennai   total sales = 944120    and total customers = 42
-- 3. Bangalore total sale = 860110     and total customers = 39

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
