-- 5.1
SELECT CASE
        WHEN LENGTH IS NOT NULL THEN CONCAT(TITLE, ' is ', LENGTH, ' minutes')
        ELSE CONCAT(TITLE, ' is unknown length')
    END AS LENGTH_DESC
FROM FILM;
-- 5.2
SELECT CONCAT(
        SUBSTR(TITLE, 1, 3),
        REPEAT('*', LENGTH(TITLE) - 3)
    ),
    LENGTH(TITLE) AS "Guess!"
FROM FILM;
-- 5.3
SELECT round(
        100.0 * count(*) FILTER (
            WHERE rating = 'NC-17'
        ) / count(*)
    ) AS "% NC-17",
    round(
        100.0 * count(*) FILTER (
            WHERE rating = 'PG'
        ) / count(*)
    ) AS "% PG",
    round(
        100.0 * count(*) FILTER (
            WHERE rating = 'G'
        ) / count(*)
    ) AS "% G",
    round(
        100.0 * count(*) FILTER (
            WHERE rating = 'R'
        ) / count(*)
    ) AS "% R",
    round(
        100.0 * count(*) FILTER (
            WHERE rating = 'PG-13'
        ) / count(*)
    ) AS "% PG-13"
FROM film;
-- 5.4
SELECT int '33';
-- 33
SELECT int '33.3';
-- invalid input
SELECT cast(33.3 AS int);
-- 33
SELECT cast(33.8 AS int);
-- 34
SELECT 33::text;
-- '33'
SELECT 'hello'::varchar(2);
-- he
SELECT cast(35000 AS smallint);
-- smallint out of range
SELECT 12.1::numeric(1, 1);
-- numeric field overflow
-- 5.5
SELECT '2019-03-04 3:30pm EST'::timestamptz,
    '2019-03-04 3:30pm America/New_York'::timestamptz,
    '2019-03-04 15:30 -05:00'::timestamptz;
-- 5.6
SELECT title,
    make_interval(days = > rental_duration) AS duration,
    make_interval(days = > rental_duration + 1) AS "duration + 1"
FROM film;
-- 5.7
SELECT date_part('hour', rental_date) AS "hr",
    count(*)
FROM rental
GROUP BY hr
ORDER BY hr;
-- 5.8
SELECT date_trunc('month', payment_date) AS MONTH,
    sum(amount) AS total
FROM payment
GROUP BY MONTH
ORDER BY MONTH;
-- 5.9
SELECT sum(
        CASE
            WHEN extract(
                'day'
                FROM rental_date
            ) = 31
            AND extract(
                'month'
                FROM rental_date
            ) IN (1, 3, 5, 7, 8, 10, 12) THEN 1
            WHEN extract(
                'day'
                FROM rental_date
            ) = 30
            AND extract(
                'month'
                FROM rental_date
            ) IN (4, 6, 9, 11) THEN 1
            WHEN extract(
                'month'
                FROM rental_date
            ) = 2
            AND extract(
                'day'
                FROM rental_date
            ) IN (27, 28) THEN 1
            ELSE 0
        END
    ) AS "total # EOM rentals|"
FROM rental;
-- the more elegant solution from the course:
SELECT count(*) AS "total # EOM rentals"
FROM rental
WHERE date_trunc('month', rental_date) + interval '1 month' - interval '1 day' = date_trunc('day', rental_date);
-- 5.10
SELECT title
FROM film
WHERE length(trim(title)) <> length(title);
-- 5.11
SELECT customer_id,
    sum(
        extract(
            'epoch'
            FROM return_date - rental_date
        ) / 3600
    )::int AS hrs_rented
FROM rental
GROUP BY customer_id
ORDER BY hrs_rented DESC
LIMIT 3;
-- 5.12
SELECT (
        '2019-' || generate_series(1, 12) || '-01 05:00pm UTC'
    )::timestamptz;
-- the solution from the course:
SELECT *
FROM generate_series(
        timestamptz '2019-01-01 17:00 UTC',
        timestamptz '2019-12-01 17:00 UTC',
        interval '1 month'
    );
-- 5.13
SELECT first_name,
    length(first_name) - length(replace(lower(first_name), 'a', '')) AS COUNT
FROM customer
ORDER BY COUNT DESC;
-- 5.14
SELECT sum(amount) AS "total $"
FROM payment
WHERE extract(
        'isodow'
        FROM payment_date
    ) >= 6;