
CREATE DATABASE dannys_diner;
USE dannys_diner;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales VALUES('A', '2021-01-01', '1');
 INSERT INTO sales VALUES ('A', '2021-01-01', '2');
  INSERT INTO sales VALUES('A', '2021-01-07', '2');
  INSERT INTO sales VALUES('A', '2021-01-10', '3');
  INSERT INTO sales VALUES('A', '2021-01-11', '3');
 INSERT INTO sales VALUES ('A', '2021-01-11', '3');
  INSERT INTO sales VALUES('B', '2021-01-01', '2');
  INSERT INTO sales VALUES('B', '2021-01-02', '2');
 INSERT INTO sales VALUES ('B', '2021-01-04', '1');
 INSERT INTO sales VALUES ('B', '2021-01-11', '1');
  INSERT INTO sales VALUES('B', '2021-01-16', '3');
 INSERT INTO sales VALUES ('B', '2021-02-01', '3');
  INSERT INTO sales VALUES('C', '2021-01-01', '3');
 INSERT INTO sales VALUES ('C', '2021-01-01', '3');
  INSERT INTO sales VALUES('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu VALUES ('1', 'sushi', '10');
 INSERT INTO menu VALUES  ('2', 'curry', '15');
  INSERT INTO menu VALUES ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members VALUES('A', '2021-01-07');
  INSERT INTO members VALUES('B', '2021-01-09');
  
  
 -- 1-What is the total amount each customer spent at the restaurant?
 SELECT customer_id, sum(price) as total_price FROM menu m
 join sales s ON m.product_id = s.product_id
 group by customer_id;
 
 
 -- 2- How many days has each customer visited the restaurant?
 select customer_id , count(distinct(order_date)) as days_visited from sales
 group by customer_id;
 
 -- 3- What was the first item from the menu purchased by each customer?
 SELECT  customer_id, product_name, order_date FROM menu m
 join sales s ON m.product_id = s.product_id 
 where order_date >= "2021-01-01"
 group by s.customer_id
;
 
 -- 4- What is the most purchased item on the menu? how many times was it purchased by all customers?
	 SELECT  product_name, count(s.product_id) as no_of_items_sold  FROM menu m
	 join sales s ON m.product_id = s.product_id
	 group by product_name;
     
     -- 5- how many times was it purchased by all customers each?
     SELECT  customer_id, product_name, count(m.product_id) as no_items_purchased
     FROM menu m
	 join sales s ON m.product_id = s.product_id
     where product_name = 'ramen'
     group by customer_id;
     
    -- 6- Which item was the most popular for each customer?
     SELECT  customer_id ,product_name, count(s.product_id) as times_purchased  FROM menu m
	 join sales s ON m.product_id = s.product_id
	 group by  s.product_id,customer_id
     order by times_purchased desc, customer_id ;
 
-- 7- Which item was purchased first by the customer after they became a member?
SELECT  me.customer_id, m.product_name FROM menu m
	 join sales s ON m.product_id = s.product_id 
     join members me ON s.customer_id = me.customer_id
     where join_date is not null and order_date > join_date
     group by customer_id;
     
    -- 8- Which item was purchased just before the customer became a member?
    SELECT  me.customer_id, m.product_name,order_date FROM menu m
      join sales s ON m.product_id = s.product_id 
     join members me ON s.customer_id = me.customer_id
     where join_date is not null and order_date < join_date
     group by customer_id;
     
    -- 9- What is the total items and amount spent for each member before they became a member?
    SELECT  me.customer_id,order_date, sum(price) as amt_spent_by_nonmemebers FROM menu m
      join sales s ON m.product_id = s.product_id 
     join members me ON s.customer_id = me.customer_id
     where join_date is not null and order_date < join_date
     group by customer_id;
     
    -- 10- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
     with CTE as( select s.customer_id,
     CASE
     when s.product_id = 1 then(count(s.product_id) * 20 * m.price)
     else (count(s.product_id)* 10 * m.price)
      end as points
      from sales s
      join menu m on s.product_id = m.product_id
      group by s.customer_id , s.product_id)
      select customer_id, SUM(points) as loyalty_points
      from CTE 
      group by customer_id;

-- 11- In the first week after a customer joins the program(including their join date) they earn 2x points on all items, how many points do customer A and B have at the end of January?
with new_cte as (select s.customer_id, m.price, s.order_date, me.join_date, 
date_add(me.join_date, interval 6 DAY) AS one_week
from sales s
join menu m on s.product_id = m.product_id
join members me on s.customer_id = me.customer_id),
Cte as (select customer_id, order_date,
case when order_date between join_date and one_week then price  * 20
else price * 10
end as points from new_cte)
select customer_id , sum(points) as loyalty_points 
from cte
where order_date < "2021-02-01"
group by customer_id;

 -- 12- Join tables
 select s.customer_id, s.order_date, m.product_name, m.price,
 case when s.order_date>= me.join_date then "Y"
 else "N" end as member
 from sales s 
 join menu m on s.product_id = m.product_id
 join members me on s.customer_id = me.customer_id
 order by customer_id, order_date, price desc;
 
 -- 13- ranking
 with cte as( select s.customer_id, s.order_date, m.product_name, m.price,
 case when s.order_date>= me.join_date then "Y"
 else "N" end as member
 from sales s 
 join menu m on s.product_id = m.product_id
 join members me on s.customer_id = me.customer_id)
 select *,
 Case when member = "N" then "null"
 else rank() over (partition by customer_id, member 
 order by order_date) end as ranks
 from cte
 ;