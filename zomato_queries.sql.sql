CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- 1. Customer Table
CREATE TABLE customers(
customer_id INT PRIMARY KEY,
name VARCHAR(100),
gender VARCHAR(10),
	signup_date Date,
    location VARCHAR(100)
);

-- 2.Product Table
CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR (50),
price DECIMAL(10,2),
stock_quantity INT
);

-- 3.Orders Table 
CREATE TABLE orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
total_amount DECIMAL (10,2),
FOREIGN KEY (customer_id) REFERENCES customers ( customer_id)
);

-- 4.Order Item Table 
CREATE TABLE order_items (
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
item_price DECIMAL(10,2),
FOREIGN KEY (order_id) REFERENCES orders (order_id),
FOREIGN KEY (product_id) REFERENCES products (product_id)
);

INSERT INTO customers VALUES 
(1, 'Riya Sharma', 'Female', '2024-12-01', 'Delhi'),
(2, 'Arjun Mehta', 'Male', '2025-01-10', 'Mumbai'),
(3, 'Fatima Khan', 'Female', '2025-02-15', 'Bangalore'),
(4, 'Dev Joshi', 'Male', '2025-03-05', 'Delhi'),
(5, 'Sneha Patel', 'Female', '2025-03-20', 'Hyderabad');

INSERT INTO products VALUES
(101, 'Bluetooth Speaker', 'Electronics', 1499.00, 50),
(102, 'Yoga Mat', 'Fitness', 799.00, 100),
(103, 'LED Desk Lamp', 'Home Decor', 1199.00, 35),
(104, 'Cotton T-Shirt', 'Apparel', 499.00, 200),
(105, 'Notebook Pack', 'Stationery', 299.00, 150);

INSERT INTO orders VALUES
(1001, 1, '2025-03-22', 2298.00),
(1002, 2, '2025-03-25', 499.00),
(1003, 3, '2025-03-30', 1998.00),
(1004, 4, '2025-04-02', 299.00),
(1005, 1, '2025-04-10', 1499.00);

INSERT INTO order_items VALUES
(1, 1001, 101, 1, 1499.00),
(2, 1001, 105, 1, 299.00),
(3, 1001, 104, 1, 499.00),
(4, 1002, 104, 1, 499.00),
(5, 1003, 101, 1, 1499.00),
(6, 1003, 102, 1, 499.00),
(7, 1004, 105, 1, 299.00),
(8, 1005, 101, 1, 1499.00);

#1.How many new customers joined each month?
SELECT MONTH(signup_date) AS month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY MONTH(signup_date)
ORDER BY month;

#2: How much revenue are we making each month?
SELECT MONTH (order_date) AS month,
SUM(total_amount) AS monthly_revenue
FROM orders 
GROUP BY MONTH(order_date)
ORDER BY MONTH;

 #3: Which 5 products brought in the most money?
	SELECT p.product_name,
    SUM(oi.quantity*oi.item_price) AS total_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_revenue DESC
    LIMIT 5;
 
 -- 4: Who are our top 5 customers based on how much they spent
SELECT c.name AS customer_name,
    SUM(oi.quantity*oi.item_price) AS total_spent
    FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 5;

-- 5: Which products were sold the most (by quantity)?
SELECT p.product_name,
SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 6: Total revenue by each product category
SELECT p.category,
SUM(oi.quantity*oi.item_price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 7: Total revenue per month
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
SUM(oi.quantity * oi.item_price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

-- 8: Repeat Customers
SELECT c.customer_id, c.name,
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) > 1 
ORDER BY total_orders DESC;


 -- “How much revenue comes from repeat customers vs new customers?”
WITH customer_order_counts AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
),

orders_with_type AS (
    SELECT 
        o.order_id,
        o.customer_id,
        CASE 
            WHEN coc.total_orders > 1 THEN 'Repeat'
            ELSE 'New'
        END AS customer_type
    FROM orders o
    JOIN customer_order_counts coc ON o.customer_id = coc.customer_id
),

revenue_split AS (
    SELECT 
        ow.customer_type,
        SUM(oi.quantity * oi.item_price) AS total_revenue
    FROM orders_with_type ow
    JOIN order_items oi ON ow.order_id = oi.order_id
    GROUP BY ow.customer_type
)

SELECT * FROM revenue_split;

#Top 5 Customers by Revenue
SELECT 
    c.customer_id,
    c.name AS customer_name,
    SUM(oi.quantity * oi.item_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 5;




















