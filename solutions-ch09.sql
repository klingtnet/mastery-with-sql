-- 9.1
(
    select cast(rental_date as date) as interaction_date
    from rental
)
union
(
    select cast(payment_date as date) as interaction_date
    from payment
)
order by interaction_date;
-- 9.2
(
    select first_name,
        last_name
    from customer
)
intersect
(
    select first_name,
        last_name
    from actor
);
-- 9.3
(
    select film_id
    from film_actor
    where actor_id = 49
)
intersect
(
    select film_id
    from film_actor
    where actor_id = 152
)
intersect
(
    select film_id
    from film_actor
    where actor_id = 180
);
-- 9.4
(
    select generate_series(
            (
                select min(rental_id)
                from rental
            ),
            (
                select max(rental_id)
                from rental
            )
        )
)
except (
        select rental_id
        from rental
    );
-- 9.5
select first_name,
    last_name
from (
        (
            select customer_id
            from rental
            where extract(
                    isodow
                    from rental_date::timestamp
                ) = 6
        )
        except (
                select customer_id
                from rental
                where extract(
                        isodow
                        from rental_date::timestamp
                    ) = 7
            )
    ) as t(customer_id)
    inner join customer using (customer_id)
order by first_name;
-- 9.6
(
    select cast(rental_date as date) as interaction_date,
        'rental' as type
    from rental
)
union
(
    select cast(payment_date as date),
        'payment' as type
    from payment
)
order by interaction_date;
-- 9.7
select country
from (
        (
            select country_id
            from staff
                inner join address using(address_id)
                inner join city using (city_id)
        )
        intersect
        (
            select country_id
            from customer
                inner join address using(address_id)
                inner join city using (city_id)
        )
    ) as t(country_id)
    inner join country using(country_id);
-- 9.8
(
    A
    except B
)
intersect
(
    B
    except A
)