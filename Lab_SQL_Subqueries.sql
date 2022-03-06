USE sakila;

/* 1. How many copies of the film Hunchback Impossible exist in the inventory system?

6 copies */

SELECT count(inventory_id) FROM sakila.inventory
Where film_id = (
SELECT film_id FROM sakila.film
WHERE title="Hunchback Impossible"
);


/* 2. List all films whose length is longer than the average of all the films. */

SELECT title FROM film
WHERE length > (SELECT avg(length) FROM film);


/* 3. Use subqueries to display all actors who appear in the film Alone Trip. */

SELECT first_name, last_name, actor_id FROM sakila.actor
WHERE actor_id IN (
SELECT actor_id from sakila.film_actor 
WHERE film_id = (SELECT film_id FROM sakila.film
WHERE title="Alone Trip"));


/* 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */

SELECT title FROM sakila.film
WHERE film_id IN (
SELECT film_id FROM sakila.film_category
WHERE category_id IN (
SELECT category_id from sakila.category
WHERE name = "Family")) ;


/* 5. a. Get name and email from customers from Canada using subqueries. */ 

SELECT first_name, last_name, email FROM sakila.customer
WHERE address_id IN(
SELECT address_id FROM sakila.address
WHERE city_id IN (SELECT city_id FROM sakila.city
WHERE country_id = (SELECT country_id FROM sakila.country
WHERE country="Canada"))
);

/* 5. b. Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
that will help you get the relevant information. */

SELECT first_name, last_name, email, a.address_id, co.country
FROM sakila.customer as c
JOIN sakila.address as a
ON c.address_id = a.address_id
JOIN sakila.city as ci
ON a.city_id = ci.city_id
JOIN sakila.country as co
ON ci.country_id = co.country_id
HAVING country = "Canada";

/* 6. Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred. */


SELECT title FROM film 
WHERE film_id IN(
SELECT film_id FROM film_actor 
WHERE actor_id IN (
SELECT actor_id
FROM film_actor GROUP BY actor_id
HAVING count(film_id)= (
SELECT MAX(Num_of_films) as sub1
FROM (
SELECT actor_id, count(film_id) as "Num_of_films" 
FROM film_actor
GROUP BY actor_id) as sub2)));



/* 7. Films rented by most profitable customer. 
You can use the customer table and payment table to find the most profitable customer 
ie the customer that has made the largest sum of payments */

SELECT title FROM film
WHERE film_id IN(
SELECT film_id FROM inventory 
WHERE inventory_id IN(
SELECT inventory_id FROM rental
WHERE customer_id IN(
SELECT customer_id
FROM payment GROUP BY customer_id
HAVING sum(amount)= (
SELECT MAX(profitability) as sub1
FROM (
SELECT customer_id, sum(amount) as "profitability" 
FROM payment
GROUP BY customer_id) as sub2))));

/* 8. Customers who spent more than the average payments. */

SELECT customer_id, first_name, last_name FROM sakila.customer c
Where c.customer_id in (   
SELECT distinct(customer_id)
FROM (SELECT distinct(customer_id), sum(amount) as total_spend
		FROM sakila.payment p
		GROUP BY customer_id) sub
WHERE total_spend > (SELECT sum(amount)/count(distinct(customer_id)) FROM sakila.payment p));

