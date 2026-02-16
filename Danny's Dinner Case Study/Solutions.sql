
-- Solutions


use dannys_diner; -- To use the database 

-- =========================================
-- Question 1:
-- What is the total amount each customer spent?
-- =========================================


select customer_id,sum(price) as total_amount_spent from sales as s 
inner join menu as m using(product_id)
group by customer_id;


-- =========================================
-- Question 2:
-- How many days has each customer visited the restaurant?
-- =========================================

select customer_id,count(distinct(order_date)) as cnt_of_days from sales group by customer_id;

-- =========================================
-- Question 3:
-- What was the first item from the menu purchased by each customer?
-- =========================================

with cte1 as (
select *,row_number() over(partition by customer_id order by order_date) as rn from sales as s inner join menu as m 
using(product_id))
select customer_id,product_name from cte1 where rn=1;

-- =========================================
-- Question 4:
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
-- =========================================

select product_name,count(*) as total_order from sales as s
inner join menu as m using(product_id) 
group by product_name order by total_order desc limit 1;

-- =========================================
-- Question 5:
-- Which item was the most popular for each customer?
-- =========================================

with cte1 as(
select customer_id,product_name,count(*)as cnt,
dense_rank() over(partition by customer_id order by count(*) desc) as drnk
from sales as s inner join menu as m using(product_id)
 group by customer_id,product_name)
 select customer_id,product_name from cte1 where drnk=1;
 
-- =========================================
-- Question 6:
-- Which item was purchased first by the customer after they became a member?
-- =========================================

with cte1 as (
select s.customer_id,m.product_name,row_number() over(partition by s.customer_id order by order_date asc) as rn from sales as s 
inner join menu as m using (product_id)
inner join members as mb  on s.customer_id=mb.customer_id and 
s.order_date > mb.join_date)
select * from cte1 where rn=1; 

-- =========================================
-- Question 7:
-- Which item was purchased just before the customer became a member?
-- =========================================

with cte1 as (
select s.customer_id,m.product_name,row_number() over(partition by s.customer_id order by order_date desc) as rn from sales as s 
inner join menu as m using (product_id)
inner join members as mb  on s.customer_id=mb.customer_id and 
s.order_date < mb.join_date)
select * from cte1 where rn=1;

-- =========================================
-- Question 8:
-- What is the total items and amount spent for each member before they became a member?
-- =========================================

select customer_id,sum(price) as total_amount,count(*) as total_item from sales as s inner join menu as m
using (product_id) inner join
members as mb using (customer_id) 
where s.order_date<mb.join_date
group by customer_id order by customer_id;

-- =========================================
-- Question 9:
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- =========================================

select customer_id,sum(case when product_name="sushi" then price * 20 else price *10 end) as Total_points
from sales as s inner join menu as m using(product_id)
group by customer_id;

-- =========================================
-- Question 10:
-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- =========================================

select s.customer_id,
sum(case when order_date between join_date and date_add(join_date,interval 7 day)
then price * 20 when product_name ="sushi" then price *20 else price * 10 end)  as total_points
from sales as s inner join menu as m using (product_id)
inner join members as mb using (customer_id) where month(order_date) <2
group by customer_id order by customer_id;