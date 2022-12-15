create database SQL_projec_1 ;

CREATE TABLE goldusers_signup(
userid integer,
gold_signup_date date
); 

INSERT INTO goldusers_signup (userid, gold_signup_date) 
values (1,'2017-09-22'),
(3,'2017-07-21');

select * from goldusers_signup;


CREATE TABLE users(
userid integer,
signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

select * from  users;

CREATE TABLE sales(
userid integer,
created_date date,
product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-02-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

select * from  sales;

CREATE TABLE product(
product_id integer,
product_name text,
price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from goldusers_signup;
select * from product;
select * from sales;
select * from users;


-- 1. What is the total Amount each coustmer spent on ZOMATO?

select a.userid, a.product_id, b.price 
from 
sales a inner join product b
on a.product_id = b.product_id;

select a.userid, sum(b.price) total_amount_spent
from 
sales a inner join product b
on a.product_id = b.product_id
group by a.userid

-- 2. How many days has each customer visited zomato?

select userid,
count(distinct created_date) distinct_days
from sales 
group by userid;

-- 3. what was the first product pusrchased by each customer?

select * from 
(select*, 
rank()
over (partition by userid order by created_date) rnk 
from sales)
a where  rnk = 1;

-- 4. what is the most purchased item on the menu and how many times was it purchased by customers?

select product_id, count(product_id)
from sales 
group by product_id;

-- 5.how many times was it purchased by customers?

select userid, count(product_id) cnt
from sales 
where product_id =
(
select product_id 
from sales 
group by product_id
order by count(product_id) desc
limit 1
)
group by userid;

-- 5.which item was the most popular for each customer?

select userid,product_id, count(product_id) cunt
from sales
group by userid;

select * from goldusers_signup;
select * from product;
select * from sales;
select * from users;

-- 6.which item was purchased first by the customer after they became a member?

select * from
(select c.*, rank()
over (partition by userid  order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from 
sales a inner join goldusers_signup b
on a.userid = b.userid
and created_date >= gold_signup_date)
c) d where rnk = 1;

-- 7.which item was purchased just before the customer became a member?

select * from
(select c.*, rank()
over (partition by userid  order by created_date desc) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from 
sales a inner join goldusers_signup b
on a.userid = b.userid
and created_date <= gold_signup_date)
c) d where rnk = 1;

-- 8.what is the total orders and amount spent for each member before the customer became a member?

select userid , count(created_date) order_purchased , sum(price) total_amt_spent from
(select c.* , d.price from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from 
sales a inner join goldusers_signup b
on a.userid = b.userid
and created_date <= gold_signup_date)
c inner join product d 
on c.product_id = d.product_id) e
group by userid;

-- 9. if buying each product generates points for Eg 5Rs= 2 Zomato points and each product has different purchasing points
-- for Eg P1 5Rs = 1 zomato point, for P2 10RS = 5 zomato point ,P3 5RS = 1 zomato point

-- calculate points collected by each customers and for which product most points have been given till now.

select userid, sum(total_points) * 2.5  total_cashback_earned from
(select e.*, amt / points total_points from 
(select d.* , case when product_id = 1 then 5 
when product_id = 1 then 5 
when product_id = 2 then 2 
when product_id = 3 then 5 
else 0 end as points from 

(select c.userid, c.product_id, sum(price) amt from
 (select a.* , b.price 
 from 
 sales a inner join product b 
 on a.product_id = b.product_id)
 c group by userid, product_id) 
 d)
 e)
 f group by userid;
 
 
select *, rank() over (order by total_points_earned desc) from
(select product_id, sum(total_points)  total_points_earned from
(select e.*, amt / points total_points from 
(select d.* , case when product_id = 1 then 5 
when product_id = 1 then 5 
when product_id = 2 then 2 
when product_id = 3 then 5 
else 0 end as points from 

(select c.userid, c.product_id, sum(price) amt from
 (select a.* , b.price 
 from 
 sales a inner join product b 
 on a.product_id = b.product_id)
 c group by userid, product_id) 
 d)
 e)
 f group by product_id) f;

-- 10. rnk all the transaction of the customers 

select *, rank() over (partition by userid order by created_date)from sales;

-- 11. Rank all the transactions for each member whenever they are a zomato gold member transction mark as NA 

select c. *,case when gold_signup_date is null then "NA" else rank() over (partition by userid order by created_date desc) end as rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from 
sales a left join goldusers_signup b
on a.userid = b.userid
and created_date >= gold_signup_date) c;
