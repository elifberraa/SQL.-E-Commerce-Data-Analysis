--Question 1 : 
--Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz.
--Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz.

SELECT oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(o.order_delivered_customer_date - o.order_approved_at) AS avg_delivery_time_hours,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL 
    AND o.order_approved_at IS NOT NULL
	AND o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY avg_delivery_time_hours ASC
LIMIT 5;

--Question 2 : 
--Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? 
--Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 

WITH seller_category_orders AS (
    SELECT oi.seller_id, 
        COUNT(DISTINCT p.product_category_name) AS category_count, 
        COUNT(DISTINCT o.order_id) AS order_count
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY 1
)
SELECT category_count,
    COUNT(seller_id) AS num_sellers,
    ROUND(AVG(order_count), 2) AS avg_order_count,
    MAX(order_count) AS max_order_count,
    MIN(order_count) AS min_order_count
FROM seller_category_orders
GROUP BY 1
ORDER BY 1 DESC;