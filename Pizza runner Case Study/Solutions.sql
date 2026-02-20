-- Creating a view so that it can be reused for the upcoming questions.

create view customer_orders_clean as 
select order_id,
customer_id,
pizza_id,
case when exclusions in ('',"null") then NULL
else exclusions end as exclusions,
case when extras in ('',"null") then NULL
else extras end as extras,
order_time from 
customer_orders;

-- creating view for runner_order

create view runner_orders_clean as
select order_id,
runner_id,
pickup_time,
case when distance in('null','') then null
else replace(distance,'km','')+0
end as distance_km,
case when duration in('','null') then null
else replace(replace(replace(duration,'minutes',''),'mins',''),'minute','')+0
end as duration_mins,
case when cancellation in ('',"null") then null
else cancellation end as cancellation
from runner_orders;

-- Now we move on to problem solving

use pizza_runner;

-- =========================================
-- Question 1:
-- How many pizzas were ordered?
-- =========================================

select count(order_id) as total_pizza from customer_orders_clean;

-- =========================================
-- Question 2:
-- How many unique customer orders were made?
-- =========================================

select count(distinct order_id)  as unique_orders from customer_orders_clean;

-- =========================================
-- Question 3:
-- How many successful orders were delivered by each runner?
-- =========================================

select runner_id,count(*) as cnt from runner_orders_clean
where cancellation is null
group by runner_id;

-- =========================================
-- Question 4:
-- How many of each type of pizza was delivered?
-- =========================================

select pizza_name,count(pizza_name) as cnt from customer_orders_clean c
join pizza_names p using(pizza_id)
group by pizza_name;

-- =========================================
-- Question 5:
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- =========================================

select customer_id,pizza_name,count(*) as cnt from customer_orders_clean c
join pizza_names p using(pizza_id)
group by customer_id,pizza_name
order by customer_id;

-- =========================================
-- Question 6:
-- What was the maximum number of pizzas delivered in a single order?
-- =========================================

select order_id,count(*) as cnt from customer_orders_clean c
join runner_orders_clean r using(order_id)
where cancellation is null
group by order_id
order by cnt desc
limit 1;

-- =========================================
-- Question 7:
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- =========================================

select customer_id,sum(case when exclusions is null and extras is null then 1 else 0 end) as no_change,
sum(case when exclusions is not null or extras is not null then 1 else 0 end) as changes from customer_orders_clean c
join runner_orders_clean r using(order_id)
where cancellation is null
group by customer_id;

-- =========================================
-- Question 8:
-- How many pizzas were delivered that had both exclusions and extras?
-- =========================================

select sum(case when exclusions is not null and extras is not null then 1 else 0 end) as count_of_extras
from customer_orders_clean c
join runner_orders_clean r using(order_id)
where cancellation is null;

-- =========================================
-- Question 9:
-- What was the total volume of pizzas ordered for each hour of the day?
-- =========================================

select hour(order_time) as hour_of_day,count(order_id) as cnt from customer_orders_clean
group by hour(order_time)
order by hour_of_day;

-- =========================================
-- Question 10:
-- What was the volume of orders for each day of the week?
-- =========================================

select dayname(order_time) as day_of_week, count(order_id) as cnt from customer_orders_clean
group by day_of_week
order by cnt desc;


-- Section 2 RUNNER AND CUSTOMER EXPERIENCE

-- =========================================
-- Question 1:
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?
-- =========================================

select floor(datediff(registration_date,"2021-01-01")/7)+1 as week_period,count(runner_id) as runners_signedup from runners
group by week_period;

-- =========================================
-- Question 2:
-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- =========================================

select runner_id,avg(timestampdiff(minute,order_time,pickup_time)) as avg_time from customer_orders_clean c
join runner_orders_clean r using(order_id)
where pickup_time is not null
group by runner_id;

-- =========================================
-- Question 3:
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- =========================================

select order_id,count(*) as cnt,timestampdiff(minute,min(c.order_time),r.pickup_time) as diff from customer_orders_clean c
join runner_orders_clean r using(order_id)
where cancellation is null
group by order_id,r.pickup_time
order by cnt desc; 

-- Yes there is a relationship between the number of pizzas and how long the order takes to prepare

-- =========================================
-- Question 4:
--  What was the average distance travelled for each customer?
-- =========================================

with cte1 as (
select distinct order_id,customer_id,distance_km from customer_orders_clean c
join runner_orders_clean using(order_id)
where cancellation is null)
select customer_id,avg(distance_km) as distance_travelled from cte1
group by customer_id;

-- =========================================
-- Question 5:
--   What was the difference between the longest and shortest delivery times for all orders?
-- =========================================

select min(duration_mins) as min,max(duration_mins) as max,MAX(duration_mins) - MIN(duration_mins) as diff 
from runner_orders_clean
where cancellation is null;

-- =========================================
-- Question 6:
--   What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- =========================================

select runner_id,avg(distance_km/(duration_mins/60)) as avg_speed from runner_orders_clean
where cancellation is null
group by runner_id;

-- # No 2 is faster than other 2

-- =========================================
-- Question 7:
--  What is the successful delivery percentage for each runner?
-- =========================================

select runner_id,count(*) as total_orders,sum(case when cancellation is null then 1 else 0 end)as successfull,
sum(case when cancellation is null then 1 else 0 end)/count(*)*100.0 as percentage from runner_orders_clean
group by runner_id;



-- SECTION 3 - INGRIDIENT OPTIMIZATION

-- =========================================
-- Question 1:
-- What are the standard ingredients for each pizza?
-- =========================================

select pizza_name,group_concat(topping_name order by topping_name) as standard_ingredients 
from pizza_recipes p 
join pizza_toppings pt
on find_in_set(pt.topping_id,replace(p.toppings,' ',''))
join pizza_names Pn
using(pizza_id)
group by pizza_name;

-- =========================================
-- Question 2:
-- What was the most commonly added extra?
-- =========================================

select topping_name,count(*) as cnt from customer_orders_clean c
join pizza_toppings on
find_in_set(topping_id,replace(extras,' ',''))
where extras is not null
group by topping_name
order by cnt desc
limit 1;

-- =========================================
-- Question 3:
-- What was the most common exclusion?
-- =========================================


select topping_name,count(*) as cnt from customer_orders_clean c
join pizza_toppings t on
find_in_set(topping_id,replace(exclusions,' ',''))
where exclusions is not null
group by topping_name
order by cnt desc
limit 1;

-- =========================================
-- Question 5:
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers					
-- Meat Lovers - Exclude Beef					
-- Meat Lovers - Extra Bacon					
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers				
-- =========================================

select order_id,
concat(pizza_name,case when exclusions_name is not null then concat(" - Exclude ", exclusions_name) else '' end,
case when extras_name is not null then concat(" - Extra ", extras_name) else '' end) as order_item
from(
select c.order_id,p.pizza_name,group_concat(distinct t_ec.topping_name order by t_ec.topping_name) as exclusions_name,
group_concat(distinct t_ex.topping_name order by t_ex.topping_name) as extras_name
from customer_orders_clean c 
join pizza_names p using(pizza_id)
left join pizza_toppings t_ec on
find_in_set(t_ec.topping_id,replace(exclusions,' ',''))
left join pizza_toppings t_ex  on
find_in_set(t_ex.topping_id,replace(extras,' ',''))
group by c.order_id,p.pizza_name) x;

-- =========================================
-- Question 6:
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders
-- table and add a 2x in front of any relevant ingredients
-- =========================================

select order_id,
    group_concat(case when ingredient_count > 1 
	then concat(ingredient_count, 'x ', topping_name)
	else topping_name
    end order by topping_name
    separator ', ')
    as ingredient_list from (
select order_id,topping_name,
count(*) as ingredient_count
from (
select c.order_id,t.topping_name
from customer_orders_clean c
join pizza_recipes pr on c.pizza_id = pr.pizza_id
join pizza_toppings t on FIND_IN_SET(t.topping_id, REPLACE(pr.toppings,' ',''))
where c.exclusions is null
or not find_in_set(t.topping_id, replace(c.exclusions,' ',''))
union all
select c.order_id,t.topping_name
from customer_orders_clean c
join pizza_toppings t on FIND_IN_SET(t.topping_id, replace(c.extras,' ',''))
where c.extras is not null) ingredients
group by order_id, topping_name) final
group by order_id;

-- =========================================
-- Question 6:
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- =========================================

select topping_name,COUNT(*) as total_quantity
from (select c.order_id,t.topping_name
  from customer_orders_clean c
  join runner_orders_clean r on c.order_id = r.order_id
  join pizza_recipes pr on c.pizza_id = pr.pizza_id
  join pizza_toppings t on FIND_IN_SET(t.topping_id, replace(pr.toppings,' ',''))
  where r.cancellation is null and (
  c.exclusions is null or not FIND_IN_SET(t.topping_id, replace (c.exclusions,' ','')))

  union all

select c.order_id,t.topping_name
from customer_orders_clean c
join runner_orders_clean r on c.order_id = r.order_id
join pizza_toppings t on FIND_IN_SET(t.topping_id, replace(c.extras,' ',''))
where r.cancellation is null AND c.extras is not null ) ingredients
group by topping_name
order by total_quantity desc;



-- Section 4

-- =========================================
-- Question 1:
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes
-- how much money has Pizza Runner made so far if there are no delivery fees?
-- =========================================

select sum(case when p.pizza_name = 'Meat Lovers' then 12
when p.pizza_name = 'Vegetarian' then 10 end)
as total_revenue
from customer_orders_clean c
join runner_orders_clean r on c.order_id = r.order_id
join pizza_names p on c.pizza_id = p.pizza_id
where r.cancellation is null;

-- =========================================
-- Question 2:
-- What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra?
-- =========================================

select sum( case when p.pizza_name = 'Meat Lovers' then 12
when p.pizza_name = 'Vegetarian' then 10
end + case
when c.extras is not null then 1 + LENGTH(c.extras) - LENGTH(replace(c.extras, ',', ''))
else 0 end)
as total_revenue_with_extras
from customer_orders_clean c
join runner_orders_clean r on c.order_id = r.order_id
join pizza_names p on c.pizza_id = p.pizza_id
where r.cancellation is null;

-- =========================================
-- Question 3:
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to
-- rate their runner, how would you design an additional table for this new dataset - generate a 
-- schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- =========================================

create table runner_ratings (
  rating_id int auto_increment primary key,
  order_id int not null,
  customer_id int not null,
  runner_id int not null,
  rating int check (rating between 1 and 5),
  rating_time timestamp default current_timestamp
);

insert into runner_ratings (order_id, customer_id, runner_id, rating) values
(1, 101, 1, 5),
(2, 101, 1, 4),
(3, 102, 1, 5),
(4, 103, 2, 3),
(5, 104, 3, 4),
(7, 105, 2, 5),
(8, 102, 2, 4),
(10, 104, 1, 5);


-- =========================================
-- Question 4:
-- Using your newly generated table - can you join all of the information together to 
-- form a table which has the following information for successful deliveries?
/* customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas */
-- =========================================


select c.customer_id,c.order_id,r.runner_id,rr.rating,c.order_time,r.pickup_time,
timestampdiff(minute, c.order_time, r.pickup_time) 
as mins_to_pickup,
r.duration_mins,ROUND(r.distance_km / r.duration_mins, 2) 
as avg_speed_km_per_min,COUNT(*) AS total_pizzas

from customer_orders_clean c
join runner_orders_clean r on c.order_id = r.order_id
join runner_ratings rr on c.order_id = rr.order_id
where r.cancellation is null
group by c.customer_id,c.order_id,r.runner_id,rr.rating,c.order_time,r.pickup_time,r.duration_mins,r.distance_km;

-- =========================================
-- Question 5:
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for 
-- extras and each runner is paid $0.30 per kilometre traveled - how much 
-- money does Pizza Runner have left over after these deliveries?
-- =========================================

with revenue as (
select sum(case when p.pizza_name = 'Meatlovers' then 12
when p.pizza_name = 'Vegetarian' then 10 else 0
end) as total_revenue
from customer_orders_clean c
join pizza_names p using (pizza_id)
join runner_orders_clean r using (order_id)
where r.cancellation is null
),
runner_cost as (
  select sum(distance_km * 0.30) as total_runner_cost
  from runner_orders_clean
  where cancellation is null
)
select total_revenue,total_runner_cost,
round(total_revenue - total_runner_cost, 2) as profit_left
from revenue, runner_cost;