-- 6.1
SELECT rental_date,
    title
FROM customer AS c
    INNER JOIN rental USING (customer_id)
    INNER JOIN inventory USING (inventory_id)
    INNER JOIN film USING (film_id)
WHERE c.first_name = 'PETER'
    AND c.last_name = 'MENARD'
ORDER BY rental_date DESC;
-- 6.2
SELECT store_id,
    first_name || ' ' || last_name AS "Manager",
    email
FROM store
    INNER JOIN staff ON store.manager_staff_id = staff.staff_id;
-- 6.3
SELECT film_id,
    title,
    count(*) AS COUNT
FROM rental AS r
    INNER JOIN inventory USING (inventory_id)
    INNER JOIN film USING (film_id)
GROUP BY film_id
ORDER BY COUNT DESC
LIMIT 3;
-- 6.4
SELECT r.customer_id,
    count(DISTINCT f.film_id) AS num_films,
    count(DISTINCT fa.actor_id) AS num_actors
FROM rental AS r
    INNER JOIN inventory AS i USING (inventory_id)
    INNER JOIN film AS f USING (film_id)
    INNER JOIN film_actor AS fa USING (film_id)
GROUP BY r.customer_id
ORDER BY r.customer_id;
-- 6.5
SELECT film.title,
    language.name AS "language"
FROM film
    INNER JOIN LANGUAGE ON film.language_id = language.language_id;
SELECT film.title,
    language.name AS "language"
FROM film
    INNER JOIN LANGUAGE USING (language_id);
-- 6.6
SELECT title
FROM film
    LEFT JOIN inventory USING (film_id)
WHERE inventory_id IS NULL;
-- 6.7
SELECT title,
    count(inventory_id) AS COUNT
FROM film
    LEFT JOIN inventory USING (film_id)
GROUP BY film_id
ORDER BY COUNT ASC;
-- 6.8
SELECT customer.customer_id,
    count(rental.rental_id) AS num_rented
FROM customer
    LEFT JOIN rental ON customer.customer_id = rental.customer_id
    AND date_trunc('day', rental_date) = '2005-05-24'
GROUP BY customer.customer_id,
    rental_id
ORDER BY num_rented DESC;
-- 6.9
SELECT title,
    store_id,
    count(stoinv.inventory_id) AS stock
FROM film
    JOIN (
        SELECT film_id,
            store_id,
            inventory_id
        FROM store
            JOIN inventory USING (store_id)
    ) AS stoinv USING (film_id)
GROUP BY title,
    store_id
ORDER BY stock ASC;
-- solution from the course:
SELECT f.film_id,
    s.store_id,
    count(i.inventory_id) AS stock
FROM film AS f
    CROSS JOIN store AS s
    LEFT JOIN inventory AS i ON f.film_id = i.film_id
    AND s.store_id = i.store_id
GROUP BY f.film_id,
    s.store_id
ORDER BY stock,
    f.film_id,
    s.store_id;
-- 6.10
SELECT m AS L,
    count(rental_id)
FROM rental AS r
    RIGHT JOIN generate_series('2005-01-01', '2005-12-31', interval '1 month') AS m ON m = date_trunc('month', r.rental_date)
GROUP BY m;
-- solution from the course for comparison:
SELECT m.t,
    count(r.rental_id)
FROM generate_series(
        '2005-01-01'::TIMESTAMP,
        '2005-12-01'::TIMESTAMP,
        '1 month'
    ) AS m (t)
    LEFT JOIN rental AS r ON date_trunc('month', r.rental_date) = m.t
GROUP BY m.t;
-- 6.11 (was also not able to figure this out in time)
SELECT r.customer_id
FROM rental AS r
    INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
    INNER JOIN rental AS r2 ON r.customer_id = r2.customer_id
    AND r2.rental_date > r.rental_date
    INNER JOIN inventory AS i2 ON r2.inventory_id = i2.inventory_id
WHERE i.film_id = 97
    AND i2.film_id = 841;