--Coffee customer count
--	Q.1. How many people in each city consume coffee given that 25% of the population does?
SELECT 
   city_name,
   ROUND((population *0.25)/1000000, 2) as coffee_consumers_in_million,
   city_rank
FROM city
ORDER BY population DESC



--Total revenue from Coffee shop
--2.What is the total revenue of coffee sales generated across all cities in the last quarter in 2023
SELECT ci.city_name,
   SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as cu
ON cu.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = cu.city_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
  AND 
      EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue 



--Q3
--Sales Count for each product
--How many unit of each coffee product has been sold?
SELECT p.product_name, COUNT(s.sale_id) as product_sold
FROM products as p
LEFT JOIN sales as s
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 2 desc



--Q.4
--Average sales amount per city
--What is the average sales amount per customer in each city
SELECT ci.city_name,  
      SUM(s.total) as total_revenue,
	  COUNT(DISTINCT s.customer_id)AS total_customer,
	  ROUND(
	  SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id)::numeric ,2) 
	  AS avg_sales_per_customer
FROM customers as cu
JOIN sales as s
ON s.customer_id = cu.customer_id
JOIN city as ci
ON ci.city_id = cu.city_id
GROUP BY 1
ORDER BY 2 DESC



--City Population and coffee consumer. (25%)
--Q.5.Provide a list of cities along with their populations and estimated coffee consumer
--Return city_name, total_current_customer, estimated_coffee_consumer

SELECT 
   ci.city_name, COUNT(DISTINCT cu.customer_id) AS unique_customer,
   ROUND((population *0.25)/1000000, 2) as coffee_consumers_in_million
FROM city as ci
JOIN customers as cu
ON ci.city_id = cu.city_id
GROUP BY 1, 3
ORDER BY 3 DESC



--Top selling product by city
--Q.6 What are the  top 3 selling product in each city by sales volume
SELECT *
FROM
	(SELECT
	    ci.city_name,
	    p.product_name, 
		COUNT(s.sale_id) AS total_order,
		DENSE_RANK() OVER (PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) desc) as rank
	FROM products as p
	JOIN sales as s
	ON p.product_id=s.product_id
	JOIN customers as cu
	ON s.customer_id = cu.customer_id
	JOIN city as ci
	ON ci.city_id = cu.city_id
	GROUP BY 1,2
	) as t1
WHERE rank <=3



--Q.7
-- Customers segmentation by city
--How many unique customers are there in each city who have purshased customers products?
SELECT 
     ci.city_name,
	 COUNT(DISTINCT cu.customer_id) AS unique_customer

FROM city as ci
LEFT JOIN customers as cu
ON ci.city_id = cu.city_id
JOIN sales as s
ON s.customer_id = cu.customer_id
WHERE s.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY 1



--Q8
--Average sales versus rent
--Find each city and its average sales per customer and avg rent per customer
SELECT ci.city_name,  
	  COUNT(DISTINCT s.customer_id)AS total_customer,
	  ROUND(
	         SUM(s.total)::numeric
			                       /COUNT(DISTINCT s.customer_id)::numeric 
			 ,2) AS avg_sales_per_customer,
			 ci.estimated_rent,
			 ROUND( ci.estimated_rent:: numeric
			                                   / COUNT(DISTINCT s.customer_id::numeric),2)
			as avg_rent_per_customer
FROM customers as cu
JOIN sales as s
ON s.customer_id = cu.customer_id
JOIN city as ci
ON ci.city_id = cu.city_id
GROUP BY 1,4
ORDER BY 5 DESC



--Q.9
--Monthly growth ratio
--Sales growth rate: Calculate the percentage growth( or decline) in sales over different time period monthly
WITH monthly_sales AS 
	(SELECT c.city_name, 
	       EXTRACT(YEAR FROM sale_date) as year,
		   EXTRACT (MONTH FROM sale_date) as month,
		   SUM(total) as total_sales
	FROM city as c
	JOIN customers as cu
	ON c.city_id = cu.city_id
	JOIN sales as s
	ON cu.customer_id = s.customer_id
	GROUP BY 1, 2,3 
	ORDER BY 1,2,3
),
last_month AS
		(SELECT city_name,
		       year,
			   month,
			   total_sales as cr_month_sale,
			   LAG(total_sales, 1) OVER(PARTITION BY city_name) AS last_month_sale
		FROM monthly_sales)
SELECT 
     city_name,
	 year,
	 month,
	 cr_month_sale,
	 last_month_sale,
	 ROUND(
	 ((cr_month_sale - last_month_sale):: numeric/last_month_sale::numeric * 100),2) as growth_ratio
FROM last_month
WHERE last_month_sale IS NOT NULL



--Q.10
--Market potential analysis
--Identify top 3 city based on highest sales, return city name, total sale, total rent, total customer, estimated consumer
SELECT ci.city_name,  
         ROUND((population *0.25)/1000000, 2) as coffee_consumers_in_mill,
	  COUNT(DISTINCT s.customer_id)AS total_customer,
	  ROUND(
	         SUM(s.total)::numeric
			                       /COUNT(DISTINCT s.customer_id)::numeric 
			 ,2) AS avg_sales_per_cx,
			 ci.estimated_rent AS total_rent,
			 ROUND( ci.estimated_rent:: numeric
			                                   / COUNT(DISTINCT s.customer_id::numeric),2)
			as avg_rent_per_cx, SUM(s.total) as total_revenue
FROM customers as cu
JOIN sales as s
ON s.customer_id = cu.customer_id
JOIN city as ci
ON ci.city_id = cu.city_id
GROUP BY 1,2,5
ORDER BY 6 DESC



--Recommendations
--1. PUNE
--a. Avg rent per city is low
--b. highest total revenue
--c. avg_sale_per_cx is also high

--2 Dehli
--a. Highest coffee consumer is 7.75 million
--b. Highest total customer of 68 person
--c. avg rent per customer is low 330.88
