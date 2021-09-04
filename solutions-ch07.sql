-- 7.1
SELECT first_name,
    last_name
FROM customer
WHERE customer_id IN (
        SELECT customer_id
        FROM rental
        WHERE date_trunc('day', rental_date) = (
                SELECT min(date_trunc('day', rental_date))
                FROM rental
            )
    );
-- solution from the course:
SELECT DISTINCT c.first_name,
    c.last_name
FROM rental AS r
    INNER JOIN customer AS c USING (customer_id)
WHERE r.rental_date::date = (
        SELECT min(rental_date)::date
        FROM rental
    );
-- 7.2
SELECT film_id,
    title
FROM film
WHERE film_id not in (
        SELECT DISTINCT film_id
        FROM film_actor
    );
-- using join
SELECT film_id,
    title
FROM film
    LEFT JOIN film_actor USING(film_id)
WHERE actor_id IS NULL;
-- 7.3
SELECT c.customer_id,
    c.first_name,
    c.last_name
FROM rental AS r1
    INNER JOIN inventory AS i1 USING (inventory_id)
    INNER JOIN customer AS c USING (customer_id)
WHERE i1.film_id = (
        SELECT i2.film_id
        FROM rental AS r2
            INNER JOIN inventory AS i2 USING (inventory_id)
        GROUP BY i2.film_id
        ORDER BY count(*) ASC,
            i2.film_id ASC
        LIMIT 1
    );
-- 7.4
SELECT country
FROM country AS c
WHERE (
        SELECT count(*)
        FROM city AS ct
        WHERE ct.country_id = c.country_id
    ) > 15;
-- 7.5
SELECT customer_id,
    first_name,
    last_name,
    (
        SELECT store_id
        FROM rental
            JOIN inventory USING(inventory_id)
        WHERE customer_id = c.customer_id
        GROUP BY store_id
        ORDER BY count(store_id) DESC
        LIMIT 1
    ) AS "Favourite Store"
FROM customer AS c;
-- 7.6
SELECT first_name,
    last_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM rental AS r
                INNER JOIN inventory USING(inventory_id)
            WHERE customer_id = c.customer_id
                AND store_id <> c.store_id
        ) THEN 'Y'
        ELSE 'N'
    END AS "HasRentedOtherStore"
FROM customer AS c;
-- 7.7
SELECT first_name,
    last_name
FROM customer
    CROSS JOIN (
        VALUES (1),
            (2),
            (3),
            (4)
    ) AS t;
-- 7.8
SELECT to_char(t.d, 'Day') AS day_name,
    round(avg(t.cnt)) AS avgerage
FROM (
        SELECT rental_date::date AS d,
            count(*) AS cnt
        FROM rental
        GROUP BY d
    ) AS t
GROUP BY day_name
ORDER BY average DESC;
-- solution from the couse:
SELECT to_char(rent_day, 'Day') AS day_name,
    round(avg(num_rentals)) AS average
FROM (
        SELECT date_trunc('day', rental_date) AS rent_day,
            count(*) AS num_rentals
        FROM rental
        GROUP BY rent_day
    ) AS T
GROUP BY day_name
ORDER BY average DESC;
-- 7.9
SELECT first_name,
    last_name,
    t.title,
    t.rental_date
FROM customer AS c
    INNER JOIN LATERAL (
        SELECT customer_id,
            title,
            rental_date
        FROM rental AS r
            INNER JOIN inventory USING(inventory_id)
            INNER JOIN film USING(film_id)
        WHERE left(rating::text, 2) = 'PG'
            AND r.customer_id = c.customer_id
        ORDER BY rental_date ASC
        LIMIT 1
    ) AS t ON t.customer_id = c.customer_id;
-- 7.10
WITH bi AS (
    SELECT customer_id,
        rental_date
    FROM rental
        INNER JOIN inventory USING(inventory_id)
        INNER JOIN film USING(film_id)
    WHERE title = 'BRIDE INTRIGUE'
),
so AS (
    SELECT customer_id,
        rental_date
    FROM rental
        INNER JOIN inventory USING(inventory_id)
        INNER JOIN film USING(film_id)
    WHERE title = 'STAR OPERATION'
)
SELECT customer_id
FROM bi
    INNER JOIN so USING(customer_id)
WHERE bi.rental_date < so.rental_date;
-- solution from couse (uses inner join):
WITH rental_detail AS (
    SELECT r.customer_id,
        r.rental_date,
        f.title
    FROM rental AS r
        INNER JOIN inventory AS i USING (inventory_id)
        INNER JOIN film AS f USING (film_id)
)
SELECT r1.customer_id
FROM rental_detail AS r1
    INNER JOIN rental_detail AS r2 ON r1.customer_id = r2.customer_id
    AND r2.rental_date > r1.rental_date
    AND r1.title = 'BRIDE INTRIGUE'
    AND r2.title = 'STAR OPERATION';
-- 7.11 (this is the course solution, was in a hurry)
WITH monthly_amounts AS (
    SELECT date_trunc('month', payment_date) AS MONTH,
        sum(amount) AS total
    FROM payment
    GROUP BY MONTH
)
SELECT curr.month,
    curr.total AS "income",
    prev.total AS "prev month income",
    curr.total - prev.total AS "change"
FROM monthly_amounts AS curr
    LEFT JOIN monthly_amounts AS prev ON curr.month = prev.month + interval '1 month' -- 7.12
select distinct customer_id
from rental as r
where to_char(rental_date, 'YYYY') = '2005'
    and not exists(
        select *
        from rental
        where to_char(rental_date, 'YYYY') = '2006'
            and customer_id = r.customer_id
    );
-- 7.13
with per_country as (
    select country,
        count(*) as num_customers
    from customer
        join address using(address_id)
        join city using(city_id)
        join country using(country_id)
    group by country
    order by num_customers desc
    limit 3
)
select *,
    round(
        100.0 * per_country.num_customers /(
            select count(*)
            from customer
        )
    ) as percent
from per_country;
-- official solution is
select country,
    count(*) as num_customers,
    round(
        100.0 * count(*) / (
            select count(*)
            from customer
        )
    ) as percent
from customer as c
    inner join address using (address_id)
    inner join city using (city_id)
    inner join country using (country_id)
group by country
order by count(*) desc
limit 3;
-- 7.14
with monthly_amounts as (
    select date_trunc('month', payment_date) as month,
        sum(amount) as amount
    from payment
    group by month
)
select ma1.month,
    ma1.amount,
    (
        select sum(ma2.amount)
        from monthly_amounts as ma2
        where ma2.month <= ma1.month
    ) as cumamount
from monthly_amounts as ma1
order by ma1.month;
-- 7.15
with id_series as (
    select generate_series(
            (
                select min(rental_id)
                from rental
            ),
            (
                select max(rental_id)
                from rental
            )
        ) as id
)
select id
from id_series
where id not in (
        select rental_id
        from rental
    );
-- official solution is
select s.id
from generate_series(
        (
            select min(rental_id)
            from rental
        ),
        (
            select max(rental_id)
            from rental
        )
    ) as s(id)
where not exists (
        select *
        from rental as r
        where r.rental_id = s.id
    );
-- 7.16
select payment_id,
    amount,
    payment_date
from (
        select payment_id,
            amount,
            payment_date
        from payment
        where payment_date >= '2007-01-01'
            and payment_date < '2007-02-01'
        order by payment_date desc
        limit 3
    ) as p
order by payment_date asc;