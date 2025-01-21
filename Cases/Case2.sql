--Question 1 : 
--Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? 
--Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız. 

WITH customer_city_orders AS (
    SELECT c.customer_id, c.customer_city, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_city
),
customer_primary_city AS (
    SELECT customer_id, customer_city, order_count,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_count DESC) AS city_rank
    FROM customer_city_orders
),
primary_city_orders AS (
    SELECT cpc.customer_id, cpc.customer_city AS primary_city, cpc.order_count
    FROM customer_primary_city cpc
    WHERE cpc.city_rank = 1
)
SELECT primary_city, SUM(order_count) AS total_orders
FROM primary_city_orders
GROUP BY primary_city
ORDER BY total_orders DESC;
