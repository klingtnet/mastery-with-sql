-- 12.1
create view vw_rental_film as
select rental_id,
    f.title,
    f.rating,
    f.length
from rental
    inner join inventory using(inventory_id)
    inner join film f using(film_id);
select *
from vw_rental_film
order by rental_id
limit 10;
-- 12.2
-- official solution is:
select c.customer_id,
    count(r.rental_id)
from customer as c
    left join (
        rental as r
        inner join vw_rental_film as rf on r.rental_id = rf.rental_id
        and rf.rating = 'R'
    ) using (customer_id)
group by c.customer_id
order by c.customer_id;
-- 12.3
create view vw_monthly_totals as (
    select date_trunc('month', payment_date) as month,
        sum(amount) total
    from payment
    group by month
);
select *
from vw_monthly_totals
order by month asc;
-- 12.4
select month,
    total as income,
    lag(total) over(
        order by month
    ) as "prev month income",
    total - lag(total) over(
        order by month
    ) as change
from vw_monthly_totals
order by month;
-- 12.5
begin;
create materialized view mvw_rental_film as
select rental_id,
    f.title,
    f.rating,
    f.length
from rental
    inner join inventory using(inventory_id)
    inner join film f using(film_id);
insert into rental(inventory_id, customer_id, staff_id, rental_date)
values(1, 1, 1, NOW());
insert into rental(inventory_id, customer_id, staff_id, rental_date)
values(2, 2, 1, NOW());
-- difference query from the official solution
(
    select *
    from vw_rental_film
    except
    select *
    from mvw_rental_film
)
union all
(
    select *
    from mvw_rental_film
    except
    select *
    from vw_rental_film
);
rollback;
-- 12.6
create or replace function unreturned_rentals (c_id int) returns bigint -- https://www.postgresql.org/docs/13/xfunc-volatility.html
    stable language sql as $$
select count(*) as unreturned_rental_count
from rental r
where customer_id = c_id
    and return_date is null;
$$;
-- 12.7
select customer_id,
    unreturned_rentals(customer_id)
from customer;
-- 12.8
create or replace function random_int(low int, high int) returns int volatile language sql as $$
select (random() *(high - low))::int + low;
$$;
-- check results
select random_int(42, 100)
from generate_series(1, 100);
-- 12.9
create or replace function eligible_for_discount(c_id int, f_id int) returns boolean language plpgsql as $$
declare unreturned_rental_count int := 0;
film_rental_count int := 0;
begin
select count(*) into unreturned_rental_count
from rental
where customer_id = c_id
    and return_date is null;
select count(*) into film_rental_count
from rental
    inner join inventory using(inventory_id)
where customer_id = 1
    and film_id = 1;
return unreturned_rental_count = 0
and film_rental_count = 0;
end $$;
select eligible_for_discount(1, 1);
-- 12.10
create or replace function fizzbuzz(n_arg int) returns setof record language plpgsql as $$
declare rec record;
begin for i in 1..n_arg loop case
    when i % 3 = 0
    and i % 5 = 0 then
    select i,
        'FizzBuzz' into rec;
when i % 3 = 0 then
select i,
    'Fizz' into rec;
when i % 5 = 0 then
select i,
    'Buzz' into rec;
else
select i,
    i::text into rec;
end case
;
return next rec;
end loop;
end $$;
select *
from fizzbuzz(20) as x(n int, fb text);