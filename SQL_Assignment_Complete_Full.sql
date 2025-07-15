
-- SQL ASSIGNMENT SOLUTIONS
-- Dataset: MavenMovies / Sakila


-- -----------------------------
-- SECTION 1: TABLE CREATION
-- -----------------------------

CREATE TABLE employees (
    emp_id INT PRIMARY KEY NOT NULL,
    emp_name TEXT NOT NULL,
    age INT CHECK (age >= 18),
    email TEXT UNIQUE,
    salary DECIMAL DEFAULT 30000
);

-- -----------------------------
-- SECTION 2: CONSTRAINTS
-- -----------------------------

-- Constraints ensure data integrity:
-- NOT NULL: Prevents null values
-- UNIQUE: Ensures all values in a column are different
-- PRIMARY KEY: Uniquely identifies each row
-- FOREIGN KEY: Enforces a link between two tables
-- CHECK: Validates values with a condition
-- DEFAULT: Assigns a default value when none is provided

-- -----------------------------
-- SECTION 3: NOT NULL & PRIMARY KEY
-- -----------------------------

-- Use NOT NULL to enforce mandatory values.
-- A PRIMARY KEY is implicitly NOT NULL.
-- Hence, a PK column cannot contain NULLs.

-- -----------------------------
-- SECTION 4: ADD & REMOVE CONSTRAINTS
-- -----------------------------

-- Adding a constraint:
ALTER TABLE employees ADD CONSTRAINT unique_email UNIQUE (email);

-- Removing a constraint:
ALTER TABLE employees DROP CONSTRAINT unique_email;

-- -----------------------------
-- SECTION 5: VIOLATING CONSTRAINTS
-- -----------------------------

-- Example:
-- INSERT INTO employees (emp_id, emp_name, age, email) VALUES (1, 'Tom', 15, 'tom@example.com');
-- Error: Check constraint violated (age < 18)

-- -----------------------------
-- SECTION 6: ALTER PRODUCTS TABLE
-- -----------------------------

ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE products ALTER COLUMN price SET DEFAULT 50.00;

-- -----------------------------
-- SECTION 7: INNER JOIN STUDENT + CLASS
-- -----------------------------

SELECT student_name, class_name
FROM students
INNER JOIN classes ON students.class_id = classes.class_id;

-- -----------------------------
-- SECTION 8: JOIN FOR PRODUCTS & ORDERS
-- -----------------------------

SELECT orders.order_id, customers.customer_name, products.product_name
FROM products
LEFT JOIN order_items ON products.product_id = order_items.product_id
LEFT JOIN orders ON order_items.order_id = orders.order_id
LEFT JOIN customers ON orders.customer_id = customers.customer_id;

-- -----------------------------
-- SECTION 9: TOTAL SALES USING SUM
-- -----------------------------

SELECT p.product_name, SUM(o.total_amount) AS total_sales
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_name;

-- -----------------------------
-- SECTION 10: INNER JOIN MULTI TABLE
-- -----------------------------

SELECT o.order_id, c.customer_name, oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id;

-- -----------------------------
-- SQL COMMANDS FOR MAVEN MOVIES DB
-- -----------------------------

SELECT * FROM actor;
SELECT * FROM customer;
SELECT DISTINCT country FROM address;
SELECT * FROM customer WHERE active = 1;
SELECT rental_id FROM rental WHERE customer_id = 1;
SELECT * FROM film WHERE rental_duration > 5;
SELECT COUNT(*) FROM film WHERE replacement_cost BETWEEN 15 AND 20;
SELECT COUNT(DISTINCT first_name) FROM actor;
SELECT * FROM customer LIMIT 10;
SELECT * FROM customer WHERE first_name LIKE 'b%' LIMIT 3;
SELECT title FROM film WHERE rating = 'G' LIMIT 5;
SELECT * FROM customer WHERE first_name LIKE 'a%';
SELECT * FROM customer WHERE first_name LIKE '%a';
SELECT city FROM city WHERE city LIKE 'a%a' LIMIT 4;
SELECT * FROM customer WHERE first_name LIKE '%NI%';
SELECT * FROM customer WHERE first_name LIKE '_r%';
SELECT * FROM customer WHERE first_name LIKE 'a____%';
SELECT * FROM customer WHERE first_name LIKE 'a%o';
SELECT * FROM film WHERE rating IN ('PG', 'PG-13');
SELECT * FROM film WHERE length BETWEEN 50 AND 100;
SELECT * FROM actor LIMIT 50;
SELECT DISTINCT film_id FROM inventory;

-- -----------------------------
-- FUNCTIONS - AGGREGATES
-- -----------------------------

SELECT COUNT(*) FROM rental;
SELECT AVG(rental_duration) FROM film;
SELECT UPPER(first_name), UPPER(last_name) FROM customer;
SELECT rental_id, MONTH(rental_date) AS rental_month FROM rental;
SELECT customer_id, COUNT(*) FROM rental GROUP BY customer_id;
SELECT store_id, SUM(amount) FROM payment GROUP BY store_id;
SELECT c.name, COUNT(*) FROM film_category fc
JOIN category c ON fc.category_id = c.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY c.name;
SELECT l.name, AVG(rental_rate) FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.name;

-- -----------------------------
-- JOINS
-- -----------------------------

SELECT f.title, c.first_name, c.last_name
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id;

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Gone with the Wind';

SELECT c.first_name, c.last_name, SUM(p.amount)
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name;

SELECT c.first_name, f.title
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE ci.city = 'London'
GROUP BY c.first_name, f.title;

-- -----------------------------
-- ADVANCED JOINS AND GROUP BY
-- -----------------------------

SELECT f.title, COUNT(*) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 5;

SELECT c.customer_id
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE i.store_id IN (1, 2)
GROUP BY c.customer_id
HAVING COUNT(DISTINCT i.store_id) = 2;

-- -----------------------------
-- WINDOW FUNCTIONS
-- -----------------------------

SELECT customer_id, RANK() OVER (ORDER BY SUM(amount) DESC) AS rank
FROM payment
GROUP BY customer_id;

SELECT film_id, rental_date, SUM(amount) OVER (PARTITION BY film_id ORDER BY rental_date) AS cumulative_revenue
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id;

-- -----------------------------
-- NORMALIZATION & CTE
-- -----------------------------

-- 1NF: Identify and break repeating groups into separate rows or tables.

-- CTE for actors with film counts:
WITH ActorFilmCount AS (
  SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
  FROM actor a
  JOIN film_actor fa ON a.actor_id = fa.actor_id
  GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT * FROM ActorFilmCount;

-- CTE for film + language:
WITH FilmLang AS (
  SELECT f.title, l.name AS language, f.rental_rate
  FROM film f
  JOIN language l ON f.language_id = l.language_id
)
SELECT * FROM FilmLang;

-- CTE for revenue per customer:
WITH CustomerRevenue AS (
  SELECT customer_id, SUM(amount) AS total
  FROM payment
  GROUP BY customer_id
)
SELECT * FROM CustomerRevenue;

-- CTE with window:
WITH FilmRank AS (
  SELECT title, RANK() OVER (ORDER BY rental_duration DESC) AS rank
  FROM film
)
SELECT * FROM FilmRank;

-- CTE filter rentals > 2:
WITH FrequentCustomers AS (
  SELECT customer_id, COUNT(*) AS total_rentals
  FROM rental
  GROUP BY customer_id
  HAVING COUNT(*) > 2
)
SELECT * FROM FrequentCustomers
JOIN customer USING (customer_id);

-- CTE monthly rentals:
WITH MonthlyRentals AS (
  SELECT MONTH(rental_date) AS month, COUNT(*) AS total
  FROM rental
  GROUP BY MONTH(rental_date)
)
SELECT * FROM MonthlyRentals;

-- Recursive CTE for reports_to:
WITH RECURSIVE Subordinates AS (
  SELECT staff_id, first_name, last_name, reports_to
  FROM staff
  WHERE reports_to IS NULL
  UNION ALL
  SELECT s.staff_id, s.first_name, s.last_name, s.reports_to
  FROM staff s
  JOIN Subordinates r ON s.reports_to = r.staff_id
)
SELECT * FROM Subordinates;

