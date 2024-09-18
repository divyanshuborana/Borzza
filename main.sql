
create table orders(
	order_id int not null,
    order_data date not null,
    order_time time not null,
    primary key(order_id)
);

create table order_details(
	order_details_id int not null,
    order_id int not null,
    pizza_id text not null,
    quantity int not null,
	primary key(order_details_id)
);
-- -----------------------------------------------------------------------------------------------------------

--                           ------------------Basic Questions:------------------
-- Retrieve the total number of orders placed.
select count(order_id) as total_orders_placed from orders;


-- Calculate the total revenue generated from pizza sales.
select ROUND(sum(p.price*d.quantity),2) as net_revenue
from order_details d join pizzas p 
on d.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
select pt.name, p.price
from pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.
select p.size, count(od.order_details_id) as size_quantity
from order_details od join pizzas p on od.pizza_id = p.pizza_id
group by p.size
order by size_quantity desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(od.quantity) as type_quantity
from order_details od join pizzas p on od.pizza_id = p.pizza_id 
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by type_quantity desc limit 5;

--                       ------------------Intermediate:------------------

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category, count(od.quantity) as category_quantity
from pizza_types pt join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.category 
order by category_quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hours, count(order_id) as order_quantity
from orders 
group by hours order by hours asc;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name)
from pizza_types 
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),2) as avg_pizza_per_day from 
(select sum(od.quantity) as quantity
from order_details od join orders o on od.order_id = o.order_id
group by o.order_date) as day_quantities;

-- Determine the top 3 most ordered pizza types based on revenue.
 
 select pt.name, sum(od.quantity*p.price) as revenue
 from order_details od join pizzas p on p.pizza_id = od.pizza_id
 join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
 group by pt.name
 order by revenue desc
 limit 3;



--                                   ------------------Advanced------------------

-- Calculate the percentage contribution of each pizza type to total revenue.

select pt.pizza_type_id , 
round(sum(quantity*price)*100/(select sum(quantity*price) from order_details od join pizzas p on od.pizza_id = p.pizza_id),2) as precentage_revenue from
order_details od join pizzas p on od.pizza_id = p.pizza_id 
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.pizza_type_id
order by precentage_revenue desc;

-- Analyze the cumulative revenue generated over time.

select sales.order_date, sum(sales.revenue) over (order by order_date) as cumi_revenue
from (select o.order_date, sum(od.quantity*p.price) as revenue
from orders o join order_details od on o.order_id = od.order_id
join pizzas p on p.pizza_id = od.pizza_id group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name, revenue from 
(select category, name, revenue, 
rank() over (partition by category order by revenue desc ) as ranking from 
(select category, pt.name, sum(od.quantity*p.price) as revenue
from pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by category, pt.name) as a) as b 
where ranking<=3





