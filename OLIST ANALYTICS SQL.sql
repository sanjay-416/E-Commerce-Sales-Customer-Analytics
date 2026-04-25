create database olist_database;
use olist_database;
select * from olist_customers_dataset;
select * from olist_geolocation_dataset;
select * from olist_order_items_dataset;
select * from olist_order_payment_dataset;
select * from olist_order_reviews_dataset;
select * from olist_orders_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * from product_category_name_translation;

------ kpis
---- KPI 1 weekday vs weekend (order_purchase_timestamp) payment statistics
SELECT 
CASE 
WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1,7) THEN 'Weekend'
ELSE 'Weekday'
END AS day_type,
COUNT(o.order_id) AS total_orders,
SUM(p.payment_value) AS total_payment,
AVG(p.payment_value) AS avg_payment
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
GROUP BY day_type;

----- KPI 2 no.of orders with review score 5 and payment type credit card
SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
ON o.order_id = r.order_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';

----- KPI 3 average no.of days taken for order_delivered_customer_date for pet_shop
SELECT 
ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),0) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop';

---- KPI 4 avg price and payment value from customers of sao paulo city
SELECT 
AVG(oi.price) AS avg_product_price,
AVG(pay.payment_value) AS avg_payment_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_order_payments_dataset pay ON o.order_id = pay.order_id
WHERE c.customer_city = 'São Paulo';

----- KPI 5 relationship between shipping days(order_delivered-customer_date -order_purchase_timestamp ) vs review scores
 SELECT 
r.review_score,
ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 0) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r 
ON o.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score;

----- KPI 6 on-time delivery rate
SELECT 
ROUND(
SUM(CASE 
WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
ELSE 0
END) 
/ COUNT(*) * 100, 2) AS on_time_delivery_rate
FROM olist_orders_dataset;

----- KPI 7 total no.of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM olist_customers_dataset;

----- Kpi 8 top 5 cities by orders
SELECT 
c.customer_city AS city,
COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 5;

----- KPI 9 average product price of all products sold
SELECT 
ROUND(AVG(price), 2) AS avg_product_price
FROM olist_order_items_dataset;

----- KPI 10 avg review score
SELECT ROUND(AVG(review_score), 2) AS avg_review_score
FROM olist_order_reviews_dataset;