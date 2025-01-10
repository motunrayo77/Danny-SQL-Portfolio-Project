--Miscellaneous
select *
from dannys_diner.menu n;

select *
from dannys_diner.sales s;

select *
from dannys_diner.members m;
select count(order_date)
from dannys_diner.sales;

Q1--What is the total amount each customer spent at the restaurant?
--for CustomerA

SELECT
	customer_id,
	sum(price) as total_amt_spent
from (
	SELECT
		customer_id,
		product_name,
		n.product_id,
		price
	from dannys_diner.sales s
	inner join dannys_diner.menu n
	on s.product_id = n.product_id
	where customer_id = 'A')
group by customer_id;

--for customerB

SELECT
	customer_id, 
	sum(price) as total_amt_spent
from (
	SELECT
		customer_id,
		product_name, 
		n.product_id,
		price
	from dannys_diner.sales s
	inner join dannys_diner.menu n
	on s.product_id = n.product_id
	where customer_id = 'B')
group by customer_id;

--for customerC

SELECT
	customer_id, 
	SUM(price) AS total_amt_spent
FROM (
	SELECT
		customer_id,
		product_name,  
		n.product_id, price
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu n
	ON s.product_id = n.product_id
	WHERE customer_id = 'C')
GROUP BY customer_id;



Q2--How many days has each customer visited the restaurant?
--for customer A
SELECT
	customer_id, 
	COUNT( day_of_month) AS c_dam
FROM(
	SELECT
		customer_id, 
		product_name,  
		order_date,
		EXTRACT (DAY FROM order_date) as day_of_month
	FROM dannys_diner.sales s
	  INNER JOIN dannys_diner.menu n
	  ON s.product_id = n.product_id
	  WHERE customer_id = 'A'
	  ORDER BY customer_id)
GROUP BY customer_id;

--for customer B
SELECT
	customer_id,
	COUNT(day_of_month) AS c_dam
FROM(
	SELECT
		customer_id, 
		product_name, 
		order_date,
		EXTRACT (DAY FROM order_date) as day_of_month
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu n
	ON s.product_id = n.product_id
	WHERE customer_id = 'B'
	ORDER BY customer_id)
GROUP BY customer_id;

--for customer C
SELECT
	customer_id, 
	COUNT(day_of_month) AS c_dam
FROM(
 	SELECT
		customer_id,
		product_name,
		order_date, 
		EXTRACT (DAY FROM order_date) as day_of_month
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu n
	ON s.product_id = n.product_id
	WHERE customer_id = 'C'
	ORDER BY customer_id
)
GROUP BY customer_id;


Q3--What was the first item from the menu purchased by each customer?

SELECT*
FROM(SELECT
	 s.customer_id, 
	 n.product_name,  
	 s.order_date, 
  	 ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date)AS category
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu n
	ON s.product_id = n.product_id
	)
WHERE category = 1;


Q4--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	product_name,
	COUNT(*)
FROM(
	SELECT
	s.customer_id,
	n.product_name,
	s.order_date, 
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS f_item
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu n
	ON s.product_id = n.product_id)
GROUP BY product_name;


Q5--Which item was the most popular for each customer?
WITH tab_1 AS (
	SELECT
		s.customer_id,
		n.product_name, 
		COUNT(*)AS frequency,
		ROW_NUMBER()OVER (PARTITION BY customer_id ORDER BY product_name)AS a_cat 
		FROM dannys_diner.sales s
		INNER JOIN dannys_diner.menu n
		ON s.product_id = n.product_id
		GROUP BY customer_id, product_name
		ORDER BY frequency 
)
SELECT *
FROM tab_1
WHERE a_cat = 1;


Q6--which item was purchasedfirstby thecustomer###

WITH tab_2 AS (
	SELECT 
		product_name,
		s.customer_id,
		s.product_id,
		m.join_date, 
		order_date
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	On n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
)
SELECT*
FROM tab_2
WHERE order_date = '2021-01-07'OR
	  order_date >= '2021-01-09'
ORDER BY order_date DESC;


Q7--Which item was purchased just before the customer became a member?
---Customer C wasn't found on the membership table, therefore not a member

WITH tab_2 AS (
	SELECT
		product_name,
		s.customer_id, 
		s.product_id,
		m.join_date,
		order_date,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS part
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
)
SELECT *
FROM tab_2
WHERE order_date < '2021-01-07' OR
	  order_date < '2021-01-09'
ORDER BY customer_id ;


Q8--Whatis the total itemsand amount spentforeachmemberbefore they became amember?

---FORA 
WITH tab_2 AS (
	SELECT 
		product_name, 
		s.customer_id,
		s.product_id,
		m.join_date, 
		order_date, 
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS part
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
)
SELECT 
	product_name, 
	customer_id,
	COUNT(*)AStotal_A
FROM tab_2
WHERE order_date < '2021-01-07' AND customer_id = 'A'
GROUP BY customer_id, 
		 product_name;

---forB
WITH tab_2 AS(
	SELECT
		product_name,
		s.customer_id, 
		s.product_id, 
		m.join_date,
		order_date, 
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date) ASpart
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
)
SELECT
	product_name, 
	customer_id,
	COUNT(*)AS total_A
FROM tab_2
WHERE order_date < '2021-01-09' AND customer_id = 'B'
GROUP BY customer_id,
		 product_name;


--Amount_spent b4 membershipA

fora totalamountspent
WITH tab_2 AS (
	SELECT
		n.product_name,
		s.customer_id,
		s.product_id,
		m.join_date,
		order_date,
		price
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
	WHERE order_date < '2021-01-07' AND s.customer_id = 'A'
)

SELECT
	customer_id, 
	SUM(price) AS s_price
FROM tab_2
GROUP BY customer_id;

--forB

WITH tab_2 AS (
	SELECT
		n.product_name,
		s.customer_id,
		s.product_id, 
		m.join_date,
		order_date, 
		price
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
	WHERE order_date < '2021-01-09' AND s.customer_id = 'B'
)

SELECT
	customer_id,
	SUM(price) AS s_price
FROM tab_2
GROUP BY customer_id;


Q9--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH tab_3 AS ( 
	SELECT
		n.product_name, 
		s.customer_id,
		s.product_id,
		m.join_date,
		order_date, 
		price, 
		(price*10) AS points
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id )

SELECT
	customer_id,
	product_name points,
	CASE
	WHEN product_name = 'sushi' THEN points*2
	ELSE points
	END AS total_points
FROM tab_3;


--Pointsfor reach customer,customerA
WITH tab_3 AS (
	SELECT
		n.product_name, 
		s.customer_id, 
		s.product_id, 
		m.join_date, 
		order_date, price, 
		(price*10) AS points
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id
)

SELECT
	SUM(total_points)
FROM (
	SELECT
		customer_id,
		product_name,
		points,
		CASE
		WHEN product_name = 'sushi' THEN points*2
		ELSE points
		END AS total_points
	FROM tab_3)
	WHERE customer_id = 'A';

--Pointsfor reach customer,customerB
WITH tab_3 AS (
	SELECT
		n.product_name,
		s.customer_id, 
		s.product_id,
		m.join_date, 
		order_date,
		price, 
		(price*10) AS points
	FROM dannys_diner.menu n 
	JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id )

SELECT
	SUM(total_points)
FROM 
	(SELECT
		 customer_id,
		 product_name,
		 points,
		 CASE WHEN product_name = 'sushi' THEN points*2
		 ELSE points
		 END AS total_points
	 FROM tab_3)
WHERE customer_id = 'B';


Q10--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH tab_4 AS (
	SELECT
		n.product_name,
		s.customer_id, 
		s.product_id, 
		m.join_date, 
		order_date, 
		price,
		(price*20) AS points
	FROM dannys_diner.menu n 
	INNER JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	INNER JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id 
	WHERE order_date BETWEEN '2021-01-07' AND '2021-01-31'AND s.customer_id = 'A'
)
SELECT
	SUM(points)AS s_points, 
	customer_id
FROM tab_4
GROUP BY customer_id
ORDER BY  customer_id, s_points;


Q10-2---B

WITH tab_4 AS (
	SELECT
		n.product_name, 
		s.customer_id,
		s.product_id, 
		m.join_date, 
		order_date, 
		price,
		(price*20) AS points
	FROM dannys_diner.menu n 
	INNER JOIN dannys_diner.sales s
	ON n.product_id = s.product_id
	INNER JOIN dannys_diner.members m
	ON s.customer_id = m.customer_id 
	WHERE order_date BETWEEN '2021-01-07' AND '2021-01-31' AND s.customer_id = 'B'
)
SELECT
	SUM(points)AS s_points,
	customer_id
FROM tab_4
GROUP BY customer_id
ORDER BY customer_id, s_points;
