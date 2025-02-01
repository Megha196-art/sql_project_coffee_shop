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


7. **Customer Segmentation by City**  
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
   

8. **Average Sale vs Rent**  
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


9. **Monthly Sales Growth**  
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

**Ahmedabad**
2023: Growth was unstable, with fluctuations from January to July. Sales stabilized from August to November, with September and November recording the highest growth rates. November had the highest monthly sales (21,250), but December saw a steep decline.

2024: Overall growth remained low. August saw the lowest growth (-71.79%), while May recorded the highest growth (32.91%).

**Bangalore**
2023: June recorded 0% growth, indicating sales were the same in May and June (37,790). September had the highest growth (130.92%), while November had the highest monthly sales (106,100).

2024: April saw the steepest decline (-77.57%), while September recorded the highest growth (74.72%). The highest monthly sales occurred in February (60,650).

**Chennai**
2023: September had the highest growth rate (174.69%), while December recorded the highest decline (-31.74%). The highest monthly sales were from September to December, with October having the highest (124,650). August had the lowest sales (27,850).

2024: July recorded the highest growth rate (60.87%), while October saw the steepest decline (-98.48%). February recorded the highest sales (75,950), while October had the lowest (350). No records after October.

**Delhi**
2023: September had the highest growth rate (228.65%), while August saw the largest decline (-24.97%). The highest sales period was from September to December, with December recording the highest (85,690). January had the lowest sales (15,680).

2024: May saw the highest growth, while October recorded the steepest decline. The highest monthly sales occurred in March (77,800), while October had the lowest (900).

**Hyderabad**
2023: Recorded some of the highest growth rates, September (112.86%) being the highest, followed by November (103.68%), May (93.44%), and February (91.24%). November had the highest monthly sales (19,350), while January had the lowest (2,170).

2024: August recorded the highest growth (79.17%), while April had the highest decline (-71.60%). March recorded the highest sales (12,500), but there was a steady decline after March, with July recording the lowest sales (1,200).

**Indore**
2023: June recorded the highest growth (27,429%), while August had the highest decline (-46.90%). Sales were high from September to December, peaking in November (1,850). May had the lowest sales (1,750).

2024: May recorded the highest growth (125.53%), while June saw the steepest decline (-80.50%). Sales were steady from January to March, with March recording the highest sales (112,050), while August had the lowest sales (1,250).

**Jaipur**
2023: September had the highest growth (223.21%), while June recorded the highest decline (-42.34%). The highest sales period was from September to December, with December recording the highest sales (93,830) and August the lowest (16,800).

2024: September recorded the highest growth (45.66%), while October had the highest decline (-96.03%). March had the highest sales (71,100), while October recorded the lowest (900).

**Kanpur**
2023: September had the highest growth (152.50%), followed by October (136.63%). December saw the highest decline (-29.22%). The highest sales were from September to December, with November recording the highest (28,100). July had the lowest sales (2,320).

2024: May saw the highest growth (254.55%), while April recorded the highest decline (-81.92%). February had the highest sales (20,650), while September had the lowest (2,550).

**Kolkata**
2023: March recorded the highest growth (160.78%), followed by October (144.06%). The highest decline was in December (-33.02%) and April (-32.33%).

2024: June recorded the highest growth (142.19%), while April saw the steepest decline (-79.42%). February had the highest sales (15,950), while October had the lowest (1,500).

**Lucknow**
2023: August had the highest growth (190.70%), followed by June (182.35%) and March (155.56%). January had the highest decline (-67.51%). The highest sales were from August to December, with December recording the highest (18,250) and May the lowest (850).

2024: August recorded the highest growth (81.25%), while April saw the highest decline (-78.95%). The highest sales were in March (10,450), while September had the lowest (1,450).

**Mumbai**
2023: September had the highest growth (246.67%), while July saw the highest decline (-50.89%). The highest sales were from September to December, with November recording the highest (26,350) and August the lowest (4,500).

2024: August had the highest growth (158.33%), while April had the highest decline (-85.78%). Sales were steady, peaking in March (21,450) and hitting the lowest in April (3,050).

**Nagpur**
2023: September had the highest growth (208.33%), while April recorded the highest decline (-49.07%). The highest sales were in November (16,650), while January had the lowest (2,000).

2024: August saw the highest growth (111.43%), while April had the highest decline (-62.85%). February had the highest sales (12,800), while July had the lowest (1,750).

**Pune**
2023: September recorded the highest growth (217.99%), while August saw the highest decline (-48.95%). Sales remained steady throughout the year, with November recording the highest (169,350) and August the lowest (27,800).

2024: May had the highest growth (64.51%), while October recorded the highest decline (-96.83%). March had the highest sales (97,150), while October recorded the lowest (850). Sales were relatively steady in 2024.

**Surat**
2023: March had the highest growth (323.13%), while February recorded the highest decline (-66.32%). September to December saw the highest sales, with November recording the highest (18,250) and February the lowest (1,600).
2024: February saw the highest growth (46.19%), while April recorded the highest decline (-57.06%). January had the highest sales (16,400), while September recorded the lowest (2,950).


10. **Market Potential Analysis**  
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
