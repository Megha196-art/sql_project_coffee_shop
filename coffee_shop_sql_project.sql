-- Coffee business data analysis

USE business_exp_sql_project;

SELECT * FROM city;
SELECT * FROM customers; 
SELECT * FROM products;
SELECT * FROM sales;

-- Business problems and solutions

-- Q1. How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT
      city_id,
      city_name,
      ROUND((population * 0.25)/1000000, 2) as coffee_cust_in_millions,
      city_rank
FROM city
ORDER BY coffee_cust_in_millions DESC;   
-- top 5 citites with highest number of coffee consumers are Delhi, Mumbai, Kolkata, Banagalore, Chennai

-- Q2. What is the total revenue generated from coffee sales across all cities in the last quarter of year 2023?

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
-- for the last quarter of 2023, the top 5 cities that had the highest revenue generated are Pune, Chennai, Bangalore, Jaipur, Delhi

-- Q2. pt2. same thing but FY 2023 ('2023-11-01' to '2024-02-29')

SELECT 
       city_name,
       SUM(total_sale) as total_revenue
FROM sales as s
INNER JOIN customers as c
ON s.customer_id = c.customer_id
INNER JOIN city as ci
ON c.city_id = ci.city_id
WHERE sale_date BETWEEN '2023-11-01' AND '2024-02-29'
GROUP BY city_name
ORDER BY total_revenue DESC; 
-- for the last quarter of FY2023, the top 5 cities that had the highest revenue generated are Pune, Chennai, Jaipur, Bangalore, Delhi


-- Q3. How many units of each coffee product have been sold?

SELECT 
      p.product_name,
      COUNT(sale_id) as product_total_sales
FROM products as p
LEFT JOIN sales as s
ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY product_total_sales DESC;

-- can recmmendd what products to sell while opening a coffee shop. 
-- if we look at specifically coffee products cld brew coffee pack had the highest units sold followed by ground espresso, instant coffee powder and coffee bean
-- another thing to notice is that non coffee items like 'tote bag with coffee design' had significant sales
-- the store could offer diversified items


-- Q4. What is the average sales amount per customer in each city?

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

-- the 5 highest avg sales per customer can be seen in Pune, Chennai, Banaglore, Jaipur and Delhi


-- Q5. Provide a list of cities along with their populations and estimated coffee consumers.

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
-- in terms of unique customers Jaipur, Delhi, Pune, Chennai and Bangalore have the highest no. of unique customers

-- Q6. What are the top 3 selling products in each city based on sales volume?

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

-- top 3 selling products in each city
-- Ahmedabad  Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g)               - Instant Coffee Powder (100g)
-- Bangalore  Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)
-- Chennai    Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g)               - Instant Coffee Powder (100g)
-- Delhi      Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)      - Coffee Beans (500g)
-- Hyderabad  Instant Coffee Powder (100g)      - Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)
-- Indore     Instant Coffee Powder (100g)      - Ground Espresso Coffee (250g)     - Cold Brew Coffee Pack (6 Bottles)   - Coffee Beans (500g)
-- Jaipur     Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g)               - Instant Coffee Powder (100g)
-- Kanpur     Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Coffee Beans (500g)
-- Kolkata    Ground Espresso Coffee (250g)     - Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g) 
-- Lucknow    Instant Coffee Powder (100g)      - Coffee Beans (500g)               - Cold Brew Coffee Pack (6 Bottles)   - Ground Espresso Coffee (250g)
-- Mumbai     Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)      - Cold Brew Coffee Pack (6 Bottles)
-- Nagpur     Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)      - Coffee Beans (500g)                 - Cold Brew Coffee Pack (6 Bottles)
-- Pune       Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)
-- Surat      Coffee Beans (500g)               - Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)

-- acros citties cold brew coffee pack has been one of the highest selling products
-- followed by ground espresso coffee
-- followed by instant powder coffee


-- Q7. How many unique customers are there in each city who have purchased coffee products?

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

-- top three coffee products with highest unique customers
-- Ahmedabad  Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g)               - Instant Coffee Powder (100g)        - Ground Espresso Coffee (250g)
-- Bangalore  Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)        - Coffee Beans (500g)
-- Chennai    Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g)               - Instant Coffee Powder (100g)        - Ground Espresso Coffee (250g)
-- Delhi      Instant Coffee Powder (100g)      - Ground Espresso Coffee (250g)     - Coffee Beans (500g)
-- Hyderabad  Instant Coffee Powder (100g)      - Coffee Beans (500g)               - Cold Brew Coffee Pack (6 Bottles)
-- Indore     Coffee Beans (500g)               - Instant Coffee Powder (100g)      - Ground Espresso Coffee (250g)       - Vanilla Coffee Syrup (250ml)         - Cold Brew Coffee Pack (6 Bottles)
-- Jaipur     Coffee Beans (500g)               - Instant Coffee Powder (100g)      - Cold Brew Coffee Pack (6 Bottles)   - Ground Espresso Coffee (250g)
-- Kanpur     Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Coffee Beans (500g)
-- Kolkata    Ground Espresso Coffee (250g)     - Cold Brew Coffee Pack (6 Bottles) - Coffee Beans (500g) 
-- Lucknow    Instant Coffee Powder (100g)      - Coffee Beans (500g)               - Cold Brew Coffee Pack (6 Bottles)   - Ground Espresso Coffee (250g)
-- Mumbai     Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)      - Cold Brew Coffee Pack (6 Bottles)
-- Nagpur     Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)      - Coffee Beans (500g)                 - Cold Brew Coffee Pack (6 Bottles)
-- Pune       Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)     - Instant Coffee Powder (100g)
-- Surat      Coffee Beans (500g)               - Cold Brew Coffee Pack (6 Bottles) - Ground Espresso Coffee (250g)


-- Q8. Find each city and their average sale per customer and avg rent per customer

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
-- Pune, Chennai and Bangalore have the highest average sale per customer and the rent per customer is also relatively low
-- In terms of lowest rent, jaipur as the lowest average rent
-- But top ideal choice to open a store location would be Pune ( with the highest average sale per customer and lowest rent per customer)


-- Q9. Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city

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
GROUP BY 1 , 2 , 3
ORDER BY 1 , 3 , 2
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

-- Ahmedabad (2023) - the growth isn't stable. From January t July there have been constant fluctuations with alternate months expereincing growth and decline in sales. Sales were stable from August to November, with September and November seeing the highest growth rate. December again saw a steep decline in growth. Highest monthly sales recorded in November (21250)
-- Ahmedabad (2024) - Overall growth was low. Month of August seeing the lowest growth in sales (-71.79) and month of May seeing the highest growth (32.91)
-- Bangalore (2023) - Motnh of June saw 0 growth/ decline indicating May and June having the sale amount of sales (37790). Highest growth recorded inSeptember (130.92), highest monthly sales recorded in Novemeber (106100)
-- Bangalore (2024) - April saw the highest decline in growth rate (-77.57). September recorded the highest growth rate (74.72). February recorded the highest monthly sale (60650)
-- Chennai   (2023) - September recorded the highest growth rate (174.69) and December recorded the highest decline in growth (-31.74). Sepetmebr to December recorded the highest monthly sales (September 76500), (Oct 124650 highest), (Nov 105700) and (Dec 72150). Aug recrded the lowest monthly sale (27850)
-- Chennai   (2024) - July recorded the highest growth rate (60.87) and highest decline in growth in October (-98.48). No records after the month of october 2024. Feb recorded the highest monthly sale (75950) and Oct recorded the lowest monthly sale (350)
-- Delhi     (2023) - Sept recorded the highest growth rate (228.65) and Aug recorded the highest decline in growth (-24.97). Month from September to December had the highest sales (Sept 56200), (Oct 85150), (Nov 67650) and (Dec 85690 highest). Jan 2023 recrded the lowest monthly sale (15680)
-- Delhi     (2024) - May recorded the highest growth rate and highest decline in Oct. Highest monthly sales in March (77800) and lowest monthly sales in Oct (900)
-- Hyderabad (2023) - Hyderabad reocrded some of the highest growth rates with the highest being recorded in Sept (112.86), followed by Nov (103.68) , May (93.44) and in Feb (91.24). The highest decline went upto (-38.27) in the month of August. Nov recorded the highest monthly sale (19350), followed by dec (16210) and (Oct (9500). So spet to Dec had high monthly sales. January had th elowest sales (2170)
-- Hyderabad (2024) - Aug recorded the highest growth rate (79.17) and Apr recrded the highest decline (71.60). Jan to March had high mothly sales volume with MArch having the highest (12500) and then there was a ssteady decline in sales with July recording the lowest sales (1200)
-- Indore    (2023) - highest growth in june (27429) and lowst growth in august (--46.90). sept to dec high sales. nov having the highest minthly sales (1850) and lowest in may (1750)
-- Indore    (2024) - may had the hghest growth (125.53) and june had the highest decline (-80.50). steady sales from jan to march. march had the highest sales (112050) and aug had the lowest sales (1250)
-- Jaipur    (2023) - sept had the highets growth (223.21) and june had the highest decline (-42.34). sept t dec highest sales . dec had the highest sales (93830), followed by nov (77850), oct (76900) and sept (54300). lowest sales aug (16800)
-- Jaipur    (2024) - sept highest growth (45.66) and highest decline in oct (-96.03). march highest sales (71100) and oct lowest (900)
-- Kanpur    (2023) - sept highest growth (152.500) followed by oct (136.63). dec highest decline (-29.22). sept to dechighest sales. nov had highest sales (28100) followed by oct (23900), dec (19890) and sept (10100). july had the lowest sales (2320)
-- Kanpur    (2023) - may highest growth (254.55) and apr highest decline (-81.92). feb had highest sales (20650) and sep lowest sales (2550)
-- Kolkata   (2023) - march highest growth (160.78) and oct (144.06). highest decline in growth in dec (-33.02 ) and apr (-32.33)
-- Kolkata   (2024) - june highest growth (142.19) and lowest growth in apr (-79.42). feb highest sales (15950). jan to march had highest sales and then steady decline. lowest sales in oct (1500)
-- Lucknow   (2023) - highest growth in aug (190.70) fllowed by june (182.35) and march (155.56). highest decline in growth in jan (-67.51). aug to dec high sales period with highest in dec (18250). lowest sales r4ecorded in may (850). lucknow had steady growth rate and steady sales in 2023
-- Lucknow   (2024) - highest growth in aug (81.25) and highest decline in apr (-78.95). high sales period from jan to march with sudden declne in sales from april to july. highest monthlys ales recorded in march (10450) and lowest minthly sales recorded in sept (1450)
-- Mumbai    (2023) - highest growth in sept (246.67) and highest decline in growth in july (-50.89). high sales period from spet to dec. highest sales in th emonth of nov (26350) and lowest sales in aug (4500)
-- Mumbai    (2024) - highest growth in aug (158.33) and highest decline in growth (apr (-85.78). steady sales in mumbai 2024. high sales from jan to march. highest sales in march (21450) and lowest slaes in apr (3050)
-- Nagpur    (2023) - sept highest growth (208.33) and highest decline in growth in apr (-49.07). sept to dec high sales . highest monthly sales in nov (16650) an dlest sales in jan (2000)
-- Nagpur    (2024) - aug highest growth (111.43) and highest decline in apr (-62.85). highest sales in feb (12800) and lowest monthly sales in july (1750)
-- Pune      (2023) - sept highest growth (217.99) and highets decline in growth in aug (-48.95). steady sales throughout the year. hihgehst monthy sale in nov (169350) and lowest monthy sale in 27800.
-- Pune      (2024) - highest growth in may (64.51) an dhighest decline in growth (-96.83). highest sales in march (97150) and lowest sales in oct (850). sales has been steady in pune 2024 comparatively
-- Surat     (2023) - highest growth rate in (323.13) and highest decline in growth feb (-66.32). could have spends in marketing or other costs incurred that led to a decline and then a sharp risein growth march. highest sales period sept to dec. highest sales in nov ( 18250) and lowest sales in feb (1600). feb had lowest sales as well as highest decline in growth as well in 2023
-- Surat     (2024) - highest growth in feb (46.19) and highest decline in apr (-57.06). jan had highest sales (16400) and lowest sales in sept (2950)


-- Q10. Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

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

-- top three citites in terms of total sales 
-- 1. pune total sales = (1258290) and total customers = 52
-- 2. chennai total sales = 944120 and total customers = 42
-- 3. bangalore total sale = 860110 and total customers = 39







