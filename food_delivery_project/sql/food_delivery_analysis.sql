-----------------------------------------TABLE CREATION--------------------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id VARCHAR(10),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE orders (
    order_id VARCHAR(10),
    customer_id VARCHAR(10),
    restaurant_id VARCHAR(10),
    order_date VARCHAR(30),
    order_time VARCHAR(20),
    order_amount INT,
    delivery_time INT,
    order_status VARCHAR(20)
);

CREATE TABLE restaurants (
    restaurant_id VARCHAR(10),
    restaurant_name VARCHAR(100),
    location VARCHAR(50),
    cuisine VARCHAR(50),
    rating FLOAT,
    avg_cost INT
);

CREATE TABLE delivery (
    delivery_id VARCHAR(10),
    order_id VARCHAR(10),
    delivery_partner VARCHAR(50),
    distance INT,
    delivery_status VARCHAR(20)
);

CREATE TABLE payments (
    payment_id VARCHAR(10),
    order_id VARCHAR(10),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20)
);


--------------------------------------------------SQL DATA CLEANING-------------------------------------------------------------



SELECT * FROM customers LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM restaurants LIMIT 10;
SELECT * FROM delivery LIMIT 10;
SELECT * FROM payments LIMIT 10;

SELECT COUNT(*) 
FROM customers
WHERE gender IS NULL OR city IS NULL;

SELECT COUNT(*) 
FROM orders
WHERE order_date IS NULL OR order_time IS NULL;

UPDATE customers
SET gender = 'Male'
WHERE gender IN ('male', 'M');

UPDATE customers
SET gender = 'Female'
WHERE gender IN ('F');

UPDATE restaurants
SET cuisine = 'Indian'
WHERE cuisine = 'indian';

UPDATE orders
SET order_status = 'Delivered'
WHERE order_status = 'delivered';

DELETE FROM orders
WHERE order_amount < 0;

DELETE FROM orders
WHERE delivery_time < 0;

DELETE FROM delivery
WHERE distance < 0;

DELETE FROM orders
WHERE order_date IS NULL;

UPDATE customers
SET gender = 'Unknown'
WHERE gender IS NULL;

DELETE FROM customers
WHERE customer_id IN (
    SELECT customer_id FROM (
        SELECT customer_id,
               ROW_NUMBER() OVER (PARTITION BY customer_id) AS rn
        FROM customers
    ) t
    WHERE t.rn > 1
);

UPDATE orders
SET order_date = TO_DATE(order_date, 'YYYY-MM-DD')
WHERE order_date LIKE '2024-%';

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM customers;

------------------------------------------------------CREATING _* CLEAN TABLES----------------------------------------------------------------------------

CREATE TABLE orders_clean AS
SELECT *
FROM orders;

CREATE TABLE customers_clean AS 
SELECT *
FROM customers;

CREATE TABLE restaurants_clean AS
SELECT * 
FROM restaurants;

CREATE TABLE delivery_clean AS 
SELECT * 
FROM delivery;

CREATE TABLE payments_clean AS
SELECT * 
FROM payments;
-------------------------------------------------- ADDITIONAL CLEANING QUERIES-----------------------------------------------------------
SELECT *
FROM customers_clean
WHERE gender IS NULL
   OR city IS NULL;

SELECT *
FROM orders_clean
WHERE order_status IS NULL
   OR order_time IS NULL;

SELECT *
FROM payments_clean
WHERE payment_method IS NULL;

UPDATE customers_clean
SET city = 'Unknown'
WHERE city IS NULL;

UPDATE orders_clean
SET order_status = 'Pending'
WHERE order_status IS NULL;

UPDATE orders_clean
SET order_time = '19:00'
WHERE order_time IS NULL;

UPDATE payments_clean
SET payment_method = 'Unknown'
WHERE payment_method IS NULL;

SELECT COUNT(*)
FROM customers_clean
WHERE city IS NULL;

SELECT COUNT(*)
FROM orders_clean
WHERE order_status IS NULL;

select count(*)
from payments_clean
where payment_method is null;


select * from customers_clean;
select * from orders_clean;
select * from restaurants_clean;

select * from delivery_clean
WHERE delivery_partner IS NULL 
     or delivery_status IS NULL;

select * from payments_clean
where payment_status IS NULL;

UPDATE delivery_clean
SET delivery_partner = 'Not Assigned'
WHERE delivery_partner IS NULL;

UPDATE payments_clean
SET payment_status = 'Pending'
WHERE payment_status IS NULL;

SELECT COUNT(*)
FROM delivery_clean
WHERE delivery_partner IS NULL
OR delivery_status IS NULL;

SELECT COUNT(*)
FROM payments_clean
WHERE payment_status IS NULL;

update delivery_clean
set delivery_status = 'Delivered'
where delivery_status = 'delivered';

select * from orders_clean;
select * from delivery_clean;

update orders_clean
set order_date = '2024-02-01'
where order_date = '01-02-2024';

ALTER TABLE orders_clean
ALTER COLUMN order_date TYPE DATE
USING order_date::DATE;

select * from payments_clean;
   
update orders_clean
set order_date = '2024-03-03'
where order_date = 'March 3 2024';


SELECT *
FROM customers_clean
ORDER BY customer_id;

select * 
from orders_clean
order by order_id;

SELECT *
FROM restaurants_clean
WHERE avg_cost <= 0;

SELECT ROUND(AVG(avg_cost),2)
FROM restaurants_clean
WHERE avg_cost > 0;

UPDATE restaurants_clean
SET avg_cost = 399.11
WHERE avg_cost <= 0;

SELECT *
FROM restaurants_clean
WHERE avg_cost <= 0;

SELECT *
FROM restaurants_clean
WHERE rating > 5
OR rating < 0;

UPDATE restaurants_clean
SET rating = 5
WHERE rating > 5;

UPDATE restaurants_clean
SET rating = 0
WHERE rating < 0;

--------------------------------------------FINAL CLEANED TABLES----------------------------------------------------------------------------------
select * from customers_clean;
select * from orders_clean;
select * from restaurants_clean;
select * from delivery_clean;
select * from payments_clean;



------------------------------------------------SQL ANALYSIS------------------------------------------------------------------------------------
CREATE TABLE food_delivery_master AS
SELECT
    o.order_id,
    o.order_date,
    o.order_time,
    o.order_amount,
    o.delivery_time,
    o.order_status,

    c.customer_id,
    c.gender,
    c.age,
    c.city,

    r.restaurant_name,
    r.cuisine,
    r.rating,
    r.avg_cost,

    d.delivery_partner,
    d.distance,
    d.delivery_status,

    p.payment_method,
    p.payment_status

FROM orders_clean o

JOIN customers_clean c
ON o.customer_id = c.customer_id

JOIN restaurants_clean r
ON o.restaurant_id = r.restaurant_id

JOIN delivery_clean d
ON o.order_id = d.order_id

JOIN payments_clean p
ON o.order_id = p.order_id;


select * 
from food_delivery_master
limit 10;

--total orders--------
select count(*) as total_orders
from food_delivery_master;

----total revenue-------
select sum(order_amount) as total_revenue
from food_delivery_master
where order_status = 'Delivered';

----avg order value--------
SELECT ROUND(AVG(order_amount),2) AS avg_order_value
FROM food_delivery_master
WHERE order_status = 'Delivered';

-----------cancellation rate-------------
SELECT 
ROUND(
100.0 * SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END)
/ COUNT(*),2
) AS cancellation_rate
FROM food_delivery_master;


----------------Revenue by City-------------------
SELECT 
    city,
    SUM(order_amount) AS revenue
FROM food_delivery_master
WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY revenue DESC;

-----------Revenue by Restaurant-------------------
SELECT 
    restaurant_name,
    SUM(order_amount) AS revenue
FROM food_delivery_master
WHERE order_status = 'Delivered'
GROUP BY restaurant_name
ORDER BY revenue DESC
LIMIT 5;


----------------------Revenue by Cuisine---------
SELECT 
    cuisine,
    SUM(order_amount) AS revenue
FROM food_delivery_master
GROUP BY cuisine
ORDER BY revenue DESC;

---------payment method-------------
SELECT 
    payment_method,
    COUNT(*) AS usage_count
FROM food_delivery_master
GROUP BY payment_method
ORDER BY usage_count DESC;

-----------total orders by gender---------------
SELECT 
    gender,
    COUNT(*) AS total_orders
FROM food_delivery_master
GROUP BY gender;

----------avg delivery time-------------------
SELECT 
ROUND(AVG(delivery_time),2) AS avg_delivery_time
FROM food_delivery_master
WHERE delivery_status = 'Delivered';


----------------cancelled orders by delivery partner----------------------
SELECT 
    delivery_partner,
    COUNT(*) AS total_cancelled_orders
FROM food_delivery_master
WHERE delivery_status = 'Cancelled'
GROUP BY delivery_partner
ORDER BY total_cancelled_orders DESC;

---------------------total orders according to city and cuisine-------------------
SELECT 
    city,
    cuisine,
    COUNT(*) AS total_orders
FROM food_delivery_master
GROUP BY city, cuisine
ORDER BY city, total_orders DESC;

----------------------peak orders dates--------------------
SELECT 
    order_date,
    COUNT(*) AS total_orders
FROM food_delivery_master
GROUP BY order_date
ORDER BY total_orders DESC;


-----------------------peak orders time---------------
SELECT 
    order_time,
    COUNT(*) AS total_orders
FROM food_delivery_master
GROUP BY order_time
ORDER BY total_orders DESC;

----------------customer who spent most on orders------------------------------
SELECT 
    customer_id,
    SUM(order_amount) AS total_spent
FROM food_delivery_master
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-------------cancelled orders by distance------------------------------
SELECT 
    distance,
    COUNT(*) AS cancelled_orders
FROM food_delivery_master
WHERE delivery_status = 'Cancelled'
GROUP BY distance
ORDER BY distance;


SELECT
    CASE
        WHEN distance BETWEEN 1 AND 3 THEN 'Short Distance'
        WHEN distance BETWEEN 4 AND 6 THEN 'Medium Distance'
        ELSE 'Long Distance'
    END AS distance_category,

    COUNT(*) AS cancelled_orders

FROM food_delivery_master

WHERE delivery_status = 'Cancelled'

GROUP BY distance_category

ORDER BY cancelled_orders DESC;

------------------------order status------------------------
SELECT COUNT(*)
FROM food_delivery_master
WHERE order_status = 'Delivered'
AND payment_status IN ('Failed', 'Pending');


SELECT 
    order_id,
    order_status,
    payment_status,
    payment_method
FROM food_delivery_master
WHERE order_status = 'Delivered'
AND payment_status IN ('Failed', 'Pending');

-----------------even though orders are delivered still can see that payment status is pending so UPDATE payment status where ever the orders are completed then delievered---------
UPDATE payments_clean
SET payment_status = 'Completed'
WHERE order_id IN (
    SELECT order_id
    FROM food_delivery_master
    WHERE order_status = 'Delivered'
    AND payment_status IN ('Failed', 'Pending')
);
----------------after updating the payment status drop the master table as it stores the previous table so run it again after updating the table
DROP TABLE food_delivery_master;

------------------top city,restaurants,rating--------------------------------------------

SELECT *
FROM (
    SELECT 
        city,
        restaurant_name,
        rating,

        RANK() OVER (
            PARTITION BY city
            ORDER BY rating DESC
        ) AS rank_num

    FROM food_delivery_master
) ranked_restaurants

WHERE rank_num = 1;

------------Revenue by city and restaurants---------------------
SELECT 
    city,
    restaurant_name,
    SUM(order_amount) AS revenue
FROM food_delivery_master
WHERE order_status = 'Delivered'
GROUP BY city, restaurant_name
ORDER BY city, revenue DESC;