SELECT * FROM olist.orders LIMIT 10;
SELECT * FROM olist.order_items LIMIT 10;

-- WHERE + ORDER BY
SELECT order_id, order_status, order_purchase_timestamp
FROM olist.orders
WHERE order_status IN ('delivered','shipped')
ORDER BY order_purchase_timestamp DESC
LIMIT 10;

-- Aggregation with COUNT/AVG/MIN/MAX
SELECT order_status,
       COUNT(*) AS cnt,
       MIN(order_purchase_timestamp) AS first_ts,
       MAX(order_purchase_timestamp) AS last_ts
FROM olist.orders
GROUP BY order_status
ORDER BY cnt DESC;

-- JOIN example
SELECT o.order_id, c.customer_city, c.customer_state, o.order_status
FROM olist.orders o
JOIN olist.customers c ON c.customer_id = o.customer_id
LIMIT 10;

-- 10 analytical questions for Olist ecommerce dataset
-- Monthly revenue (based on price + freight at item level)
WITH items AS (
  SELECT oi.order_id,
         DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
         SUM(oi.price + oi.freight_value) AS gross
  FROM olist.order_items oi
  JOIN olist.orders o USING (order_id)
  WHERE o.order_status IN ('delivered','shipped','invoiced','approved')
  GROUP BY oi.order_id, month
)
SELECT month::date AS month, SUM(gross) AS revenue
FROM items
GROUP BY month
ORDER BY month;

-- Top-10 product categories by revenue
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       ROUND(SUM(oi.price + oi.freight_value),2) AS revenue
FROM olist.order_items oi
JOIN olist.products p USING (product_id)
LEFT JOIN olist.product_category_name_translation t
       ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Top-10 cities by number of orders
SELECT c.customer_city, COUNT(*) AS orders
FROM olist.orders o
JOIN olist.customers c USING (customer_id)
GROUP BY c.customer_city
ORDER BY orders DESC
LIMIT 10;

-- Average ticket size per order
SELECT ROUND(AVG(order_total),2) AS avg_order_value
FROM (
  SELECT order_id, SUM(price + freight_value) AS order_total
  FROM olist.order_items
  GROUP BY order_id
) s;

-- Payment mix (% by payment_type)
WITH counts AS (
  SELECT payment_type, COUNT(*) AS cnt
  FROM olist.order_payments
  GROUP BY payment_type
)
SELECT payment_type,
       cnt,
       ROUND(cnt * 100.0 / SUM(cnt) OVER (), 2) AS pct
FROM counts
ORDER BY pct DESC;

-- Delivery performance (days from purchase to customer delivery)
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)))/86400.0,2) AS avg_days
FROM olist.orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY month
ORDER BY month;

-- Sellers with the largest revenue
SELECT s.seller_id,
       s.seller_city,
       ROUND(SUM(oi.price + oi.freight_value),2) AS revenue
FROM olist.order_items oi
JOIN olist.sellers s USING (seller_id)
GROUP BY s.seller_id, s.seller_city
ORDER BY revenue DESC
LIMIT 10;

-- Share of delivered vs canceled orders
SELECT order_status, COUNT(*) AS cnt
FROM olist.orders
GROUP BY order_status
ORDER BY cnt DESC;

-- Freight share in total order value (how heavy shipping is)
SELECT ROUND(AVG(freight_value / NULLIF(price + freight_value,0)) * 100, 2) AS avg_freight_share_pct
FROM olist.order_items;

-- Category-level delivery speed (fastest 10)
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)))/86400.0,2) AS avg_days
FROM olist.orders o
JOIN olist.order_items oi USING(order_id)
JOIN olist.products p USING(product_id)
LEFT JOIN olist.product_category_name_translation t
       ON t.product_category_name = p.product_category_name
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY category
HAVING COUNT(*) > 100
ORDER BY avg_days ASC
LIMIT 10;
