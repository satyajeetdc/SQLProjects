select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


SELECT C.userid,SUM(C.price) AS Purchased_Amount FROM
(
SELECT A.userid,B.price FROM sales A INNER JOIN product B ON A.product_id=B.product_id
) C
GROUP BY C.userid ORDER BY SUM(C.price) DESC;


SELECT userid,COUNT(DISTINCT created_date) AS NoOfVisits FROM sales GROUP BY userid;


SELECT A.userid,A.product_id,A.created_date FROM 
(SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date) rank FROM sales) A WHERE rank=1;


SELECT userid,product_id,COUNT(product_id) AS CountOfOrder FROM sales WHERE product_id=
(
SELECT TOP 1 product_id FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC
)
GROUP BY userid,product_id




SELECT B.userid,B.product_id,B.count FROM
(
SELECT *,RANK() OVER (PARTITION BY userid ORDER BY count DESC) rank FROM 
(
SELECT userid,product_id,COUNT(product_id) count FROM sales GROUP BY userid,product_id
)A)B
WHERE rank=1;







SELECT D.userid,D.product_id FROM 
(
SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date)Rank FROM
(
SELECT A.userid,A.created_date,A.product_id,B.gold_signup_date FROM sales A 
INNER JOIN goldusers_signup B ON A.userid=B.userid
WHERE B.gold_signup_date <= A.created_date
) C) D
WHERE Rank=1;







SELECT D.userid,D.product_id FROM 
(
SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date DESC)Rank FROM
(
SELECT A.userid,A.created_date,A.product_id,B.gold_signup_date FROM sales A 
INNER JOIN goldusers_signup B ON A.userid=B.userid
WHERE B.gold_signup_date > A.created_date
) C) D
WHERE Rank=1;



SELECT userid,COUNT(created_date) Orders_Purchased,SUM(price) Total_Spent FROM
(
SELECT C.*,D.price FROM
(SELECT A.userid,A.created_date,A.product_id,B.gold_signup_date FROM sales A 
INNER JOIN goldusers_signup B ON A.userid=B.userid
WHERE B.gold_signup_date > A.created_date) C 
INNER JOIN product D ON D.product_id=C.product_id
)E
GROUP BY userid;







SELECT F.userid,SUM(F.totalpoints) AS ZP,2.5*SUM(F.totalpoints) AS WalletBalance FROM
(
SELECT E.*,amt/points AS totalpoints FROM
(
SELECT D.*,  CASE 
WHEN product_id=1 THEN 5
WHEN product_id=2 THEN 2
WHEN product_id=3 THEN 5
ELSE 0 
END AS points FROM
(
SELECT C.userid,C.product_id,SUM(price) amt FROM
(
SELECT A.*,B.price FROM sales A INNER JOIN product B ON B.product_id=A.product_id
)C
GROUP BY userid,product_id
)D
)E
)F
GROUP BY userid;





SELECT * FROM
(
SELECT *,RANK() OVER(ORDER BY ZP DESC) rank FROM
(
SELECT product_id,SUM(totalpoints) AS ZP FROM
(
SELECT E.*,amt/points AS totalpoints FROM
(
SELECT D.*,  CASE 
WHEN product_id=1 THEN 5
WHEN product_id=2 THEN 2
WHEN product_id=3 THEN 5
ELSE 0 
END AS points FROM
(
SELECT C.userid,C.product_id,SUM(price) amt FROM
(
SELECT A.*,B.price FROM sales A INNER JOIN product B ON B.product_id=A.product_id
)C
GROUP BY userid,product_id
)D
)E
)F
GROUP BY product_id
)G
)H 
WHERE rank=1;








SELECT C.*,D.price*0.5 AS ZP FROM
(
SELECT A.userid,A.created_date,A.product_id,B.gold_signup_date FROM sales A 
INNER JOIN goldusers_signup B ON A.userid=B.userid
WHERE B.gold_signup_date <= A.created_date AND created_date <= DATEADD(YEAR,1,gold_signup_date)
)C
INNER JOIN product D ON C.product_id=D.product_id






SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date) Rank FROM sales;





SELECT E.*,CASE WHEN Rank=0 THEN 'n/a' ELSE Rank END AS Ranks FROM
(
SELECT C.*, CAST((CASE WHEN gold_signup_date IS NULL THEN 0 
ELSE  RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) END) AS VARCHAR) AS Rank FROM
(
SELECT A.userid,A.created_date,A.product_id,B.gold_signup_date FROM sales A 
LEFT JOIN goldusers_signup B ON A.userid=B.userid AND B.gold_signup_date <= A.created_date
)C
)E;
