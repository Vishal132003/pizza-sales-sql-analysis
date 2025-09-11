CREATE DATABASE pizza_db_analysis;
USE pizza_db_analysis;

-- 1. Retrieve the total number of orders placed
SELECT COUNT(*) AS total_orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza
SELECT pizza_id, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered
SELECT p.size, COUNT(*) AS order_count
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT pt.name, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- 7. Determine the distribution of orders by hour of the day
SELECT HOUR(TIME(o.time)) AS order_hour, COUNT(*) AS total_orders
FROM orders o
GROUP BY order_hour
ORDER BY order_hour;

-- 8. Join relevant tables to find the category-wise distribution of pizzas
SELECT pt.category, COUNT(DISTINCT p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day
SELECT o.date, AVG(daily_orders) AS avg_pizzas_per_day
FROM (
    SELECT o.date, SUM(od.quantity) AS daily_orders
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
) daily
JOIN orders o ON o.date = daily.date
GROUP BY o.date;

-- 10. Determine the top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue
SELECT pt.name, 
       (SUM(od.quantity * p.price) / 
       (SELECT SUM(od.quantity * p.price) FROM order_details od JOIN pizzas p ON od.pizza_id = p.pizza_id) * 100) 
       AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY percentage_contribution DESC;

-- 12. Analyze the cumulative revenue generated over time
SELECT o.date, 
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, name, revenue
FROM (
    SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rnk
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rnk <= 3;
