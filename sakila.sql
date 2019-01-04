-- ## Homework Assignment

-- * 1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name 
FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT(first_name, ' ', last_name) 
AS 'Actor Name' 
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, last_name, first_name FROM actor
WHERE first_name LIKE 'Joe';  	

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT CONCAT(first_name, ' ', last_name)
FROM actor
WHERE last_name LIKE ('%GEN%');	

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name 
FROM actor
WHERE last_name LIKE ('%LI%');

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN( 'Afghanistan', 'Bangladesh', 'China');

-- * 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(50);
SELECT first_name, middle_name, last_name 
FROM actor;

-- * 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY middle_name BLOBS;

-- * 3c. Now delete the `middle_name` column.
ALTER TABLE actor 
DROP middle_name;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(actor_id) 
FROM actor 
GROUP BY last_name;  	

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(actor_id) 
FROM actor 
GROUP BY last_name 
HAVING count(actor_id) > 1;

-- * 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE 
    (first_name = 'GROUCHO') AND
    (last_name = 'WILLIAMS')
;

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
-- I read this one eight times and feel like I am having a prolonged stroke. I cannot tell what they want me to do besides rename HARPO to GROUCHO.
UPDATE actor 
SET first_name = 'GROUCHO' 
WHERE 
    (first_name = 'HARPO') AND 
    (last_name = 'WILLIAMS')
;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 
SHOW CREATE TABLE address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

--   * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name
FROM staff s
JOIN address a
ON (s.address_id = a.address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT first_name, last_name, address 
FROM staff s 
JOIN address a 
ON (s.address_id = a.address_id);  	

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, count(actor_id)
FROM film f
INNER JOIN film_actor fa
ON (f.film_id = fa.film_id)
GROUP BY title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT title, COUNT(inventory_id)
FROM inventory i
INNER JOIN film f
ON (i.film_id = f.film_id)
WHERE title LIKE 'Hunchback Impossible'
GROUP BY title;

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

--   ```
--   	![Total amount paid](Images/total_payment.png)
--   ```
SELECT first_name, last_name, SUM(amount)
FROM payment p
JOIN customer c
ON (p.customer_id = c.customer_id)
GROUP BY p.customer_id
ORDER BY last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title FROM film
WHERE (title LIKE ('K%'))
OR (title LIKE ('Q%'))
AND (language_id = 1);

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT title, COUNT(actor_id)
FROM film_actor fa  
JOIN film f
ON (fa.film_id = f.film_id)
WHERE title = 'Alone Trip'
GROUP BY title;

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city
WHERE country_id IN  (SELECT country_id FROM country
WHERE country LIKE '%canada%')));
-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title FROM film WHERE
film_id IN (SELECT film_id FROM
film_category WHERE category_id IN
(SELECT category_id FROM category
WHERE name LIKE '%family%'));
-- * 7e. Display the most frequently rented movies in descending order.
SELECT f.title
    , COUNT(r.inventory_id)
FROM film f
INNER JOIN inventory i
    on f.film_id = i.film_id
INNER JOIN rental r
    on i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.inventory_id) DESC
LIMIT 15;
-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store, total_sales FROM sales_by_store;
-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id
    , ci.city
    , co.country
FROM store
INNER JOIN address a
ON a.address_id = store.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country co
ON ci.country_id = co.country_id
LIMIT 15;  	
-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.name, SUM(p.amount)  	
FROM category ca
INNER JOIN film_category fc
ON ca.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY ca.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;
-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE OR REPLACE VIEW sakila.v AS SELECT ca.name, SUM(p.amount)  	
FROM category ca
INNER JOIN film_category fc
ON ca.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY ca.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;
-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM v;
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW v;
-- ### Appendix: List of Tables in the Sakila DB

-- * A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

-- ```sql
-- 	'actor'
-- 	'actor_info'
-- 	'address'
-- 	'category'
-- 	'city'
-- 	'country'
-- 	'customer'
-- 	'customer_list'
-- 	'film'
-- 	'film_actor'
-- 	'film_category'
-- 	'film_list'
-- 	'film_text'
-- 	'inventory'
-- 	'language'
-- 	'nicer_but_slower_film_list'
-- 	'payment'
-- 	'rental'
-- 	'sales_by_film_category'
-- 	'sales_by_store'
-- 	'staff'
-- 	'staff_list'
-- 	'store'
-- ```