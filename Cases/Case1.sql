--Question 1 : 
--Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.

SELECT 
    TO_CHAR(order_approved_at, 'MM-YYYY') AS month_year, 
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY month_year
ORDER BY month_year;

--Question 2 : 
--Aylık olarak order status kırılımında order sayılarını inceleyiniz.

SELECT 
    TO_CHAR(order_approved_at, 'MM-YYYY') AS month_year, 
    order_status, 
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY month_year, order_status
ORDER BY month_year, order_status;

--Question 3 : 
--Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. Özel günlerde öne çıkan kategoriler nelerdir? 
--Örneğin yılbaşı, sevgililer günü…
--2016 verisinde bu dört özel günden hiçbiri yok o yüzden sorguya katmadım
--2018de de yılbaşı yok

WITH ranked_orders AS (
    SELECT t.category_name_english, TO_CHAR(o.order_approved_at, 'DD-MM-YYYY') AS date, COUNT(oi.order_id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY TO_CHAR(o.order_approved_at, 'DD-MM-YYYY') ORDER BY COUNT(oi.order_id) DESC) AS rank
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN translation t ON p.product_category_name = t.category_name
    WHERE o.order_approved_at IS NOT NULL 
    AND (
        (EXTRACT(MONTH FROM o.order_approved_at) = 2 AND EXTRACT(DAY FROM o.order_approved_at) = 14 AND EXTRACT(YEAR FROM o.order_approved_at) IN (2017, 2018)) -- Valentine's Day
        OR (EXTRACT(MONTH FROM o.order_approved_at) = 12 AND EXTRACT(DAY FROM o.order_approved_at) = 31 AND EXTRACT(YEAR FROM o.order_approved_at) = 2017) -- New Year's Eve
        OR (EXTRACT(MONTH FROM o.order_approved_at) = 5 AND EXTRACT(DAY FROM o.order_approved_at) = 14 AND EXTRACT(YEAR FROM o.order_approved_at) = 2017) -- Mother's Day 2017
        OR (EXTRACT(MONTH FROM o.order_approved_at) = 5 AND EXTRACT(DAY FROM o.order_approved_at) = 13 AND EXTRACT(YEAR FROM o.order_approved_at) = 2018) -- Mother's Day 2018
        OR (EXTRACT(MONTH FROM o.order_approved_at) = 6 AND EXTRACT(DAY FROM o.order_approved_at) = 18 AND EXTRACT(YEAR FROM o.order_approved_at) = 2017) -- Father's Day 2017
        OR (EXTRACT(MONTH FROM o.order_approved_at) = 6 AND EXTRACT(DAY FROM o.order_approved_at) = 17 AND EXTRACT(YEAR FROM o.order_approved_at) = 2018) -- Father's Day 2018
    ) 
    GROUP BY t.category_name_english, date
)
SELECT category_name_english, date, total_orders,
    CASE 
		WHEN date = '14-02-2017' THEN 'Valentine''s Day'
		WHEN date = '14-02-2018' THEN 'Valentine''s Day'
		WHEN date = '31-12-2017' THEN 'New Year''s Eve'
		WHEN date = '14-05-2017' THEN 'Mother''s Day'
		WHEN date = '13-05-2018' THEN 'Mother''s Day'
		WHEN date = '18-06-2017' THEN 'Father''s Day'
		WHEN date = '17-06-2018' THEN 'Father''s Day'
    ELSE 'Other'
END AS special_day
FROM ranked_orders
WHERE rank <= 3
ORDER BY TO_DATE(date, 'DD-MM-YYYY') ASC, total_orders DESC;

--Question 4 : 
--Haftanın günleri (pazartesi, perşembe, …) ve ay günleri (ayın 1’i, 2’si gibi) bazında order sayılarını inceleyiniz.

--Haftanın günleri
SELECT 
    TO_CHAR(order_approved_at, 'Day') AS day_of_week,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_approved_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--Ay günleri
SELECT 
    EXTRACT(DAY FROM order_approved_at) AS day_of_month, 
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_approved_at IS NOT NULL
GROUP BY 1
ORDER BY 1;





