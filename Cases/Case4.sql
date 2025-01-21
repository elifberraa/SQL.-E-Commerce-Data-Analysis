--Question 1 : 
--Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır?

SELECT c.customer_state, 
    ROUND(AVG(p.payment_installments), 2) AS avg_installments
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE p.payment_type = 'credit_card'
GROUP BY c.customer_state
ORDER BY avg_installments DESC;

--Question 2 : 
--Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. 
--En çok kullanılan ödeme tipinden en az olana göre sıralayınız.

SELECT p.payment_type, 
    COUNT(DISTINCT o.order_id) AS order_count, 
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_payment_value
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY order_count DESC;

--Question 3 : 
--Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. 
--En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?

SELECT p.product_category_name,
    COUNT(CASE WHEN pay.payment_installments = 1 THEN 1 END) AS single_payment_count,
    COUNT(CASE WHEN pay.payment_installments > 1 AND pay.payment_type = 'credit_card' THEN 1 END) AS installment_payment_count,
    ROUND(100.0 * COUNT(CASE WHEN pay.payment_installments > 1 AND pay.payment_type = 'credit_card' THEN 1 END) / COUNT(*), 2) AS installment_percentage
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY installment_percentage DESC;
