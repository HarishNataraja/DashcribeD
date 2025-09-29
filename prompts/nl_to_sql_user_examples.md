### Example 1 (Time-series aggregation)
User: "Show monthly revenue for 2024 by region."
Schema: orders(order_id, order_date, revenue, region)
Output:
{"sql":"SELECT DATE_TRUNC('month', order_date) AS month, region, SUM(revenue) AS total_revenue FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01' GROUP BY month, region ORDER BY month LIMIT 1000;","explanation":"Monthly revenue by region for 2024."}

### Example 2 (Join)
User: "Top 10 products by revenue in Q1 2025 with product names."
Schema: sales(sale_id, sale_date, product_id, revenue), products(product_id, product_name)
Output:
{"sql":"SELECT p.product_name, SUM(s.revenue) AS total_revenue FROM sales s JOIN products p ON s.product_id = p.product_id WHERE s.sale_date >= '2025-01-01' AND s.sale_date < '2025-04-01' GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 10;","explanation":"Top 10 products by revenue in Q1 2025 with names."}

### Example 3 (Ambiguous)
User: "Give me revenue by channel"
Schema: transactions(txn_id, txn_date, revenue, channel)
Output:
{"clarify":"Which time period would you like (e.g., last 30 days, year-to-date)? Also, do you want total or average revenue per channel?"}
