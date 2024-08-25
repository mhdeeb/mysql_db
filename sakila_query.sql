USE sakila;

SHOW TABLES FROM sakila;
SHOW INDEXES IN rental;
SHOW CREATE TABLE rental;

CREATE VIEW inventory_film AS
    SELECT i.inventory_id, f.film_id
    FROM
        (inventory i
            LEFT JOIN film f
            ON f.film_id = i.film_id);

CREATE VIEW rental_film  AS
    SELECT r.rental_id, ifi.film_id
    FROM
        rental r
        JOIN inventory_film ifi
        ON r.inventory_id = ifi.inventory_id;

CREATE VIEW film_rental_count AS
    SELECT film_id, COUNT(film_id) AS rentals
    FROM rental_film
    GROUP BY film_id;

CREATE VIEW actor_film AS
    SELECT
        a.actor_id, a.first_name, a.last_name, fa.film_id
    FROM
        (film_actor fa
            JOIN actor a
            ON fa.actor_id = a.actor_id);

CREATE VIEW p1 AS
    SELECT
        af.first_name, af.last_name, SUM(frc.rentals) AS rentals
    FROM
        (actor_film af JOIN film_rental_count frc
        ON af.film_id = frc.film_id)
    GROUP BY af.actor_id
    ORDER BY rentals DESC;

SELECT * FROM p1 WHERE rentals = (SELECT MAX(rentals) FROM );


CREATE VIEW rental_paid AS
    SELECT rental_id, SUM(amount) AS total FROM payment
    GROUP BY rental_id;

CREATE VIEW rental_inventory AS
    SELECT rental_id, inventory_id FROM rental;

CREATE VIEW inventory_paid AS
    SELECT inventory_id, SUM(total) AS total FROM
        (rental_inventory ri
        JOIN rental_paid rp
        ON ri.rental_id = rp.rental_id)
    GROUP BY inventory_id;

CREATE VIEW inventory_store AS
    SELECT i.inventory_id, s.store_id
    FROM 
        (inventory i JOIN store s
        ON i.store_id = s.store_id);

CREATE VIEW store_paid AS
    SELECT store_id, SUM(total) AS total
    FROM
        (inventory_paid ip
        JOIN inventory_store ist
        ON ip.inventory_id = ist.inventory_id)
    GROUP BY store_id;

CREATE VIEW store_city AS
    SELECT s.store_id, a.city_id
    FROM
        (store s
        JOIN address a
        ON s.address_id = a.address_id);

CREATE VIEW city_total AS
    SELECT sc.city_id, sp.total
    FROM
        (store_city sc
        JOIN store_paid sp
        ON sc.store_id = sp.store_id);

SELECT c.city, ct.total
FROM
    (city c
    JOIN city_total ct
    ON c.city_id = ct.city_id)
ORDER BY ct.total DESC
LIMIT 5;

SELECT (SELECT
    COUNT(*)
FROM
    (SELECT
        c.customer_id, COUNT(c.customer_id) AS rents
    FROM
        (customer c
        JOIN rental r
        ON c.customer_id = r.customer_id)
    GROUP BY c.customer_id) a
WHERE rents > 15) / (SELECT COUNT(*) FROM customer) * 100;

CREATE VIEW rental_month_total AS
    SELECT
        rental_id, MONTH(payment_date) AS mon, SUM(amount) AS total
    FROM payment
    WHERE YEAR(payment_date) = 2006
    GROUP BY rental_id, mon;

CREATE VIEW inventory_month_total AS
    SELECT
        inventory_id, mon, SUM(total) AS total
    FROM
        ((SELECT rental_id, inventory_id FROM rental) ri
        JOIN rental_month_total rmt
        ON ri.rental_id = rmt.rental_id)
    GROUP BY inventory_id, mon;

CREATE VIEW film_month_total AS
    SELECT
        i.film_id, imt.mon, SUM(imt.total) AS total
    FROM
        (inventory_month_total imt
        JOIN inventory i
        ON imt.inventory_id = i.inventory_id)
    GROUP BY i.film_id, imt.mon;

SELECT
    c.name, cmt.mon, SUM(cmt.total) AS total
FROM
    (SELECT fc.category_id, fmt.mon, fmt.total FROM(film_month_total fmt
    JOIN film_category fc
    ON fmt.film_id = fc.film_id)) cmt
    JOIN category c
    ON cmt.category_id = C.category_id
GROUP BY c.name, cmt.mon;

SELECT * FROM(film_month_total fmt
    JOIN film_category fc
    ON fmt.film_id = fc.film_id);
SELECT * FROM category;

DESCRIBE rental;
DESCRIBE inventory;
DESCRIBE film;
DESCRIBE film_actor;
DESCRIBE actor;
DESCRIBE customer;
DESCRIBE store;
DESCRIBE address;
DESCRIBE payment;
DESCRIBE city;

SELECT * FROM payment;
SHOW CREATE TABLE payment;

SHOW FULL TABLES IN sakila WHERE TABLE_TYPE LIKE 'VIEW';
DROP VIEW store_paid;