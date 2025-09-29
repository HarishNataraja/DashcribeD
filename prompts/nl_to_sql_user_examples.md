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

### Example 4 (Retail / E-Commerce: basket analysis)
User: "Top 5 product categories by sales volume in the last quarter"
Schema: orders(order_id, order_date, product_id, quantity, revenue); products(product_id, category)
Output:
{"sql":"SELECT p.category, SUM(o.quantity) AS total_sold FROM orders o JOIN products p ON o.product_id = p.product_id WHERE o.order_date >= '2025-07-01' AND o.order_date < '2025-10-01' GROUP BY p.category ORDER BY total_sold DESC LIMIT 5;","explanation":"Top 5 product categories by units sold last quarter."}

### Example 5 (Healthcare: patient visits)
User: "Average length of stay by department in 2024"
Schema: admissions(admit_id, patient_id, admit_date, discharge_date, department)
Output:
{"sql":"SELECT department, AVG(DATE_PART('day', discharge_date - admit_date)) AS avg_stay_days FROM admissions WHERE admit_date >= '2024-01-01' AND admit_date < '2025-01-01' GROUP BY department ORDER BY avg_stay_days DESC LIMIT 1000;","explanation":"Average length of stay by department for 2024."}

### Example 6 (Financial Services: loan performance)
User: "Default rate by loan type for 2025 YTD"
Schema: loans(loan_id, loan_type, status, issue_date)
Output:
{"sql":"SELECT loan_type, COUNT(*) FILTER (WHERE status='default')::DECIMAL/COUNT(*) AS default_rate FROM loans WHERE issue_date >= '2025-01-01' AND issue_date < CURRENT_DATE GROUP BY loan_type ORDER BY default_rate DESC LIMIT 1000;","explanation":"Default rate by loan type for 2025 year-to-date."}

### Example 7 (SaaS / Startups: churn analysis)
User: "Monthly churn rate for 2025"
Schema: subscriptions(user_id, start_date, end_date)
Output:
{"sql":"SELECT DATE_TRUNC('month', end_date) AS month, COUNT(*)::DECIMAL / NULLIF((SELECT COUNT(*) FROM subscriptions WHERE start_date <= DATE_TRUNC('month', end_date) AND (end_date IS NULL OR end_date >= DATE_TRUNC('month', end_date))),0) AS churn_rate FROM subscriptions WHERE end_date >= '2025-01-01' GROUP BY month ORDER BY month LIMIT 1000;","explanation":"Monthly churn rate across 2025."}
