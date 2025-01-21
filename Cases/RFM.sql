--Recency
SELECT MAX(invoicedate) AS last_order_date FROM rfm;
--2011-12-09 12:50:00
SELECT customer_id,
    EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) AS recency
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

--Frequency
SELECT customer_id,
    COUNT(DISTINCT invoiceno) AS frequency
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

--Monetary
SELECT customer_id,
    ROUND(SUM(quantity * unitprinbvgdrvsece)::numeric, 2) AS monetary
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

--Complete RFM Table
SELECT customer_id,
    EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) AS recency,
	COUNT(DISTINCT invoiceno) AS frequency,
	ROUND(SUM(quantity * unitprice)::numeric, 2) AS monetary
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

--Assigning RFM Scores
SELECT customer_id,
    EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) AS recency,
    COUNT(DISTINCT invoiceno) AS frequency,
    ROUND(SUM(quantity * unitprice)::numeric, 2) AS monetary,
    NTILE(5) OVER (ORDER BY EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) ASC) AS recency_score,
    NTILE(5) OVER (ORDER BY COUNT(DISTINCT invoiceno) DESC) AS frequency_score,
    NTILE(5) OVER (ORDER BY ROUND(SUM(quantity * unitprice)::numeric, 2) DESC) AS monetary_score
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

--Combined RFM Score	
SELECT customer_id, recency, frequency, monetary, recency_score, frequency_score, monetary_score,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score
FROM (
    SELECT customer_id,
		EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) AS recency,
		COUNT(DISTINCT invoiceno) AS frequency,
		ROUND(SUM(quantity * unitprice)::numeric, 2) AS monetary,
		NTILE(5) OVER (ORDER BY EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) ASC) AS recency_score,
		NTILE(5) OVER (ORDER BY COUNT(DISTINCT invoiceno) DESC) AS frequency_score,
		NTILE(5) OVER (ORDER BY ROUND(SUM(quantity * unitprice)::numeric, 2) DESC) AS monetary_score
	FROM rfm
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id
) AS rfm_scored;

--Customer Segmentation
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
    CASE
        WHEN recency_score = 5 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 4 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
        WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score <= 3 THEN 'New Customers'
        WHEN recency_score <= 3 AND frequency_score <= 3 AND monetary_score <= 3 THEN 'Lost Customers'
		ELSE 'General Customers'
    END AS customer_segment
FROM (
    SELECT customer_id,
       EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) AS recency,
       COUNT(DISTINCT invoiceno) AS frequency,
       ROUND(SUM(quantity * unitprice)::numeric, 2) AS monetary,
       NTILE(5) OVER (ORDER BY EXTRACT(DAY FROM AGE('2011-12-09', MAX(invoicedate))) ASC) AS recency_score,
       NTILE(5) OVER (ORDER BY COUNT(DISTINCT invoiceno) DESC) AS frequency_score,
       NTILE(5) OVER (ORDER BY ROUND(SUM(quantity * unitprice)::numeric, 2) DESC) AS monetary_score
    FROM rfm
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS rfm_scored;