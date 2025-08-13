create database dominos;
use dominos;
create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

-- retrieve total  orders placed.
select count(order_id) as Total_orders from orders;

-- Calculate total revenue generated from pizza sales.
-- quantity wise total sales 
SELECT 
    (orders_details.quantity * pizzas.price) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- Overall sales

-- Upto 2 decimal places
 SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
-- Identify  the highest priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Indentify the most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

--  list the 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS ordered_pizza
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY ordered_pizza DESC
LIMIT 5;

--  join the necessary tables to find the total quantity of each quantity ordered
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS category_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY category_ordered DESC;

-- Determine the distribution of orders by hour of the day. 
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

--  Join relevant tables to find the category wise distribution of the pizzas
SELECT 
    pizza_types.category, COUNT(pizza_types.pizza_type_id)
FROM
    pizza_types
GROUP BY pizza_types.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(avg_orders), 2)
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS avg_orders
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_avg;
    
--  determine top 3 most ordered pizzas based on revenue
SELECT 
    pizza_types.name,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            0) AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id =pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;

--  calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    round(SUM(orders_details.quantity * pizzas.price) / (SELECT 
            round(sum(orders_details.quantity * pizzas.price)) AS Total_sales
        FROM
            orders_details
                JOIN
            pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- analyse the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date) as cr from 
(select orders.order_date, sum(orders_details.quantity*pizzas.price) as revenue from orders 
join 
orders_details on orders.order_id = orders_details.order_id 
join 
pizzas on orders_details.pizza_id = pizzas.pizza_id 
group by orders.order_date) as sales;

-- determine the top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue from
(select name, category, revenue, rank() over (partition by category order by revenue desc) as rn from 
(select pizza_types.name, pizza_types.category, sum(orders_details.quantity*pizzas.price) as revenue from pizza_types 
join 
pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join orders_details on pizzas.pizza_id = orders_details.pizza_id 
group by pizza_types.name, pizza_types.category) as a) as b 
where rn<=3;