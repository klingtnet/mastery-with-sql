-- 11.1
copy playground.note_tags(note_id, tag)
from '/mastery-with-sql/ch11-note_tags.csv' with (format csv, header true);
-- 11.2
copy (
    (
        select first_name || ' ' || last_name as name,
            count(*) as note_count
        from playground.users
            inner join playground.notes on email = user_email
        group by name
        order by note_count desc
    )
) to '/mastery-with-sql/ch11-11-2.csv' delimiter ',' csv header;
-- also possible to '/mastery-with-sql/ch11-11-2.csv' with (format csv, header true);
-- 11.3
-- official solution is:
copy (
    select 'test'::text,
        33::int,
        33.3::numeric,
        33.3::real,
        true::boolean,
        current_date::date,
        current_timestamp::timestamptz,
        '1 day'::interval
) to '...output_types.txt';
-- 11.4
begin;
insert into customer(first_name, last_name, store_id, address_id)
values('Andreas', 'Linz', 1, 1)
returning *;
rollback;
-- 11.5
begin;
create table rental_stats(
    date date not null,
    num_rentals int not null
);
insert into rental_stats(date, num_rentals)
select date_trunc('day', rental_date),
    count(*)
from rental
group by rental_date
returning *;
rollback;
-- short solution using CREATE TABLE AS
begin;
create table rental_stats as
select rental_date::date as rental_day,
    count(*)
from rental
group by rental_day
order by rental_day;
rollback;
-- 11.6
begin;
update customer
set email = lower(
        first_name || '.' || last_name || '@sakilacustomer.org'
    )
returning email;
rollback;
-- 11.7
-- official solution is:
update film
set rental_rate = rental_rate * 1.1
where film_id in (
        select i.film_id
        from rental as r
            inner join inventory as i using (inventory_id)
        group by i.film_id
        order by count(*) desc
        limit 20
    );
-- 11.8
begin;
alter table film
add column length_hrs float;
update film
set length_hrs = length / 60.0
returning *;
rollback;
-- 11.9
begin;
delete from payment
where amount = 0.0
returning *;
rollback;
-- 11.10
-- Description says "Table(s) to use: language" but must include "film"
begin;
delete from language
where language_id in (
        (
            select language_id
            from language
        )
        except (
                select language_id
                from film
            )
    )
returning *;
rollback;
-- official solution is
delete from language
where language_id not in (
        select distinct language_id
        from film
    );
-- 11.11
begin;
update customer
set activebool = case
        when exists (
            select *
            from rental
            where rental.customer_id = customer.customer_id
                and rental_date >= '2006-01-01'
        ) then true
        else false
    end;
rollback;
-- 11.12
begin;
create table inventory_stats(
    store_id int references store(store_id),
    film_id int references film(film_id),
    stock_count int not null check(stock_count >= 0),
    primary key (store_id, film_id)
);
insert into inventory_stats
select store.store_id,
    film.film_id,
    sum(
        case
            when inventory.inventory_id is null then 0
            else 1
        end
    ) as stock_count
from film
    cross join store
    left join inventory on film.film_id = inventory.film_id
    and store.store_id = inventory.store_id
group by film.film_id,
    store.store_id;
select sum(stock_count)
from inventory_stats;
rollback;
-- official solution is:
create table inventory_stats (
    store_id smallint references store (store_id),
    film_id smallint references film (film_id),
    stock_count int not null,
    primary key (store_id, film_id)
);
insert into inventory_stats(store_id, film_id, stock_count)
select s.store_id,
    f.film_id,
    count(i.inventory_id)
from film as f
    cross join store as s
    left join inventory as i on f.film_id = i.film_id
    and s.store_id = i.store_id
group by f.film_id,
    s.store_id on conflict (store_id, film_id) do
update
set stock_count = excluded.stock_count;
-- note that this solution gives a sum of stocks of 4581 whereas my query returns 5060
-- 11.13
begin;
with ranked_rentals as (
    select rental_id,
        customer_id,
        return_date,
        rank() over(
            partition by customer_id
            order by return_date
        ) as rank
    from rental
),
deleted_payments as (
    delete from payment p using ranked_rentals rr
    where rr.rank = 1
        and p.rental_id = rr.rental_id
    returning rr.rental_id
)
delete from rental
where rental_id in (
        select rental_id
        from deleted_payments
    )
returning *;
rollback;
-- the official solution is simpler because it leverages Postgres' "distinct on" (https://www.geekytidbits.com/postgres-distinct-on/)
with deleted_rentals as (
    delete from rental
    where rental_id in (
            select distinct on (customer_id) rental_id
            from rental
            order by customer_id,
                rental_date
        )
    returning rental_id
)
delete from payment
where rental_id in (
        select rental_id
        from deleted_rentals
    );
-- 11.14
begin;
create table mpaa_ratings(
    rating_id smallint generated always as identity primary key,
    rating text check(length(rating) > 0)
);
insert into mpaa_ratings(rating)
select distinct rating
from film
where rating is not null;
alter table film
add column rating_id smallint references mpaa_ratings(rating_id);
update film f
set rating_id = mr.rating_id
from mpaa_ratings mr
where mr.rating =case
        when f.rating = 'NC-17' then 'NC-17'
        when f.rating = 'R' then 'R'
        when f.rating = 'G' then 'G'
        when f.rating = 'PG' then 'PG'
        when f.rating = 'PG-13' then 'PG-13'
        else null
    end;
select distinct rating
from film
    inner join mpaa_ratings using(rating_id);
alter table film drop column rating;
drop type mpaa_rating;
rollback;
-- official solution is a bit more clever:
create table mpaa_ratings (rating text primary key);
insert into mpaa_ratings
select unnest(enum_range(null::mpaa_rating));
alter table film
alter column rating drop default,
    alter column rating type text,
    alter column rating
set default 'G',
    add foreign key (rating) references mpaa_ratings(rating);
drop type mpaa_rating;