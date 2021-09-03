-- 8.1
select rental_id,
    customer_id,
    rental_date
from (
        select rental_id,
            customer_id,
            rental_date,
            rank() over (
                partition by customer_id
                order by rental_date desc
            )
        from rental
    ) as r
where rank <= 3;
-- 8.2
-- rent_counts is the common table expression (CTE) which returns film_ids ordered by rental count.
with rent_counts as (
    select film_id,
        count(*),
        rank() over (
            order by count(*)
        )
    from rental
        inner join inventory using (inventory_id)
    group by film_id
)
select distinct customer_id
from rental as r
    inner join inventory as i using (inventory_id)
where i.film_id in (
        select film_id
        from rent_counts
        where rank = 1
    );
-- 8.3
select rating
from (
        select rating,
            row_number() over (partition by rating) rownum
        from film
        where rating is not null
    ) as r
where rownum <= 1;
-- 8.4
select customer_id,
    rental_id,
    return_date - rental_date rent_duration,
    avg(return_date - rental_date) over(partition by customer_id)
from rental
limit 10;
-- 8.5
with t as (
    select date_trunc('month', payment_date) as month,
        sum(amount) amount
    from payment
    group by month
)
select month,
    amount,
    sum(amount) over(
        order by month
    ) running_total
from t;
-- 8.6
with film_incomes as (
    select f.film_id,
        f.title,
        f.rating,
        f.rental_rate * count(*) as income
    from rental as r
        inner join inventory as i using (inventory_id)
        inner join film as f using (film_id)
    group by f.film_id
),
film_rankings as (
    select film_id,
        title,
        rating,
        income,
        rank() over(
            partition by rating
            order by income desc
        )
    from film_incomes
    where rating is not null
)
select title,
    rating,
    income
from film_rankings
where rank <= 3
order by rating,
    rank;
-- 8.7
select rownum
from(
        select row_number() over(
                order by rental_id
            ) as rownum
        from rental
    ) as t
where not exists (
        select rental_id
        from rental
        where rental_id = rownum
    );
-- official solution is
with t as (
    select rental_id as current,
        lead(rental_id) over (
            order by rental_id
        ) as next
    from rental
)
select current + 1 as missing_from,
    next - 1 as missing_to
from t
where next - current > 1;
-- 8.8
with r as (
    select customer_id,
        rental_date,
        lead(rental_date) over (
            partition by customer_id
            order by rental_date
        ) as next
    from rental
)
select customer_id,
    max(next - rental_date) as longest_break
from r
where next is not null
group by customer_id
order by customer_id
limit 100;
-- official solution is
with days_between as (
    select customer_id,
        rental_date,
        lead(rental_date) over (
            partition by customer_id
            order by rental_date
        ) - rental_date as diff
    from rental
)
select customer_id,
    max(diff) as "longest break"
from days_between
group by customer_id
order by customer_id;