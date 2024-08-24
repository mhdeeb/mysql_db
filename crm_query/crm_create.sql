SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';
CREATE DATABASE IF NOT EXISTS crm;
USE crm;

CREATE TABLE IF NOT EXISTS person (
    person_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(45) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS address (
    address_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    street VARCHAR(45) NOT NULL,
    city VARCHAR(45) NOT NULL,
    state VARCHAR(45) NOT NULL,
    zip_code VARCHAR(5) NOT NULL
);

CREATE TABLE IF NOT EXISTS product_category (
    product_category_name VARCHAR(45) PRIMARY KEY,
    description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS campaign (
    campaign_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(16, 4) NOT NULL,
    description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS customer (
    customer_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    person_id INT UNSIGNED UNIQUE NOT NULL,
    address_id INT UNSIGNED,
    date_of_birth DATE,
    CONSTRAINT fk_customer__person__person_id
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON DELETE CASCADE,
    CONSTRAINT fl_customer__address__address_id
        FOREIGN KEY (address_id) REFERENCES address(address_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS connection (
    person_1_id INT UNSIGNED NOT NULL,
    person_2_id INT UNSIGNED NOT NULL,
    CONSTRAINT pk_connection
        PRIMARY KEY (person_1_id, person_2_id),
    CONSTRAINT fk_connection__person__person_1_id
        FOREIGN KEY (person_1_id) REFERENCES person(person_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_connection__person_person_2_id
        FOREIGN KEY (person_2_id) REFERENCES person(person_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sales_rep (
    sales_rep_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    person_id INT UNSIGNED UNIQUE NOT NULL,
    management_region VARCHAR(20),
    CONSTRAINT fk_sales_rep__person__person_id
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product (
    product_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    price DECIMAL(16, 4) NOT NULL,
    stock INT UNSIGNED NOT NULL,
    product_category_name VARCHAR(45) NOT NULL,
    discount TINYINT UNSIGNED NOT NULL,
    description VARCHAR(200),
    CONSTRAINT fk_product__product_category__product_category_name
        FOREIGN KEY (product_category_name)
        REFERENCES product_category(product_category_name)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS `order` (
    order_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id INT UNSIGNED NOT NULL,
    status ENUM('pending', 'completed', 'canceled') NOT NULL DEFAULT 'pending',
    start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_date DATETIME,
    CONSTRAINT fk_order__customer__customer_id
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_interaction (
    customer_interaction_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id INT UNSIGNED NOT NULL,
    sales_rep_id INT UNSIGNED NOT NULL,
    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type ENUM('phone call', 'email', 'meeting') NOT NULL,
    details VARCHAR(200) NOT NULL,
    outcome VARCHAR(200) NOT NULL,
    CONSTRAINT fk_customer_interaction__customer__customer_id
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_customer_interaction__sales_rep__sales_rep_id
        FOREIGN KEY (sales_rep_id) REFERENCES sales_rep(sales_rep_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS purchase (
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    CONSTRAINT pk_purchase_id
        PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_purchase__order__order_id
        FOREIGN KEY (order_id) REFERENCES `order` (order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_purchase__product__product_id
        FOREIGN KEY (product_id) REFERENCES product(product_id)
        ON DELETE CASCADE
);

CREATE PROCEDURE crm.add_person(
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN email VARCHAR(45),
    IN phone VARCHAR(15),
    OUT person_id INT UNSIGNED
)
BEGIN
    INSERT INTO crm.person (first_name, last_name, email, phone)
        VALUES (first_name, last_name, email, phone);
    SELECT LAST_INSERT_ID() INTO person_id;
END

CREATE FUNCTION crm.has_person (
    p_person_id INT UNSIGNED
) RETURNS TINYINT(1)
    DETERMINISTIC
BEGIN
    DECLARE person_count INT;
    SET person_count = (
        SELECT COUNT(*)
        FROM crm.person
        WHERE person_id = p_person_id
    );
    IF person_count > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END

CREATE PROCEDURE crm.add_address(
    IN street VARCHAR(45),
    IN city VARCHAR(45),
    IN state VARCHAR(45),
    IN zip_code VARCHAR(5),
    OUT address_id INT UNSIGNED
)
BEGIN
    INSERT INTO crm.address (street, city, state, zip_code)
        VALUES (street, city, state, zip_code);
    SELECT LAST_INSERT_ID() INTO address_id;
END

CREATE FUNCTION crm.has_address (
    p_address_id INT UNSIGNED
) RETURNS TINYINT(1)
    DETERMINISTIC
BEGIN
    DECLARE address_count INT;
    SET address_count = (
        SELECT COUNT(*)
        FROM crm.address
        WHERE address_id = p_address_id
    );
    IF address_count > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END

CREATE PROCEDURE crm.add_customer(
    IN date_of_birth DATE,
    IN street VARCHAR(45),
    IN city VARCHAR(45),
    IN state VARCHAR(45),
    IN zip_code VARCHAR(5),

    INOUT person_id INT UNSIGNED,
    
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN email VARCHAR(45),
    IN phone VARCHAR(15),
    
    OUT customer_id INT UNSIGNED
)
BEGIN
    DECLARE address_id INT UNSIGNED;

    IF NOT has_person(person_id)
    THEN
        CALL add_person(first_name, last_name, email, phone, person_id);
    END IF;

    INSERT INTO crm.customer (person_id, address_id, date_of_birth)
        VALUES (person_id, NULL, date_of_birth);
    SELECT LAST_INSERT_ID() INTO customer_id;
    
    CALL add_address(street, city, state, zip_code, address_id);

    UPDATE crm.customer
    SET address_id = address_id
    WHERE customer_id = customer_id;
END

CREATE PROCEDURE crm.add_product_category(
    IN product_category_name VARCHAR(45),
    IN description VARCHAR(200)
)
BEGIN
    INSERT INTO crm.product_category (product_category_name, description)
        VALUES (product_category_name, description);
END

CREATE PROCEDURE crm.add_campaign (
    IN name VARCHAR(45),
    IN start_date DATE,
    IN end_date DATE,
    IN budget DECIMAL(16, 4),
    IN description VARCHAR(200),
    OUT campaign_id INT UNSIGNED
)
BEGIN
    INSERT INTO crm.campaign (name, start_date, end_date, budget, description)
        VALUES (name, start_date, end_date, budget, description);
END

CREATE PROCEDURE crm.add_sales_rep(
    IN management_region VARCHAR(20),

    INOUT person_id INT UNSIGNED,
    
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN email VARCHAR(45),
    IN phone VARCHAR(15),
    
    OUT sales_rep_id INT UNSIGNED
)
BEGIN
    IF NOT has_person(person_id)
    THEN
        CALL add_person(first_name, last_name, email, phone, person_id);
    END IF;
    
    INSERT INTO crm.sales_rep (person_id, management_region)
        VALUES (person_id, management_region);
    SELECT LAST_INSERT_ID() INTO sales_rep_id;
END

CREATE PROCEDURE crm.add_connection (
    IN person_1_id INT UNSIGNED,
    IN person_2_id INT UNSIGNED
)
BEGIN
    INSERT INTO crm.connection (person_1_id, person_2_id)
        VALUES (person_1_id, person_2_id);
END

CREATE PROCEDURE crm.add_product (
    IN product_category_name VARCHAR(45),
    IN name VARCHAR(45),
    IN price DECIMAL(16, 4),
    IN stock INT UNSIGNED,
    IN discount TINYINT UNSIGNED,
    IN description VARCHAR(200),
    OUT product_id INT UNSIGNED
)
BEGIN
    INSERT INTO crm.product (product_category_name, name, price, stock, discount, description)
        VALUES (product_category_name, name, price, stock, discount, description);
    SELECT LAST_INSERT_ID() INTO product_id;
END

CREATE PROCEDURE crm.add_order (
    IN customer_id INT UNSIGNED,
    IN status ENUM('pending', 'completed', 'canceled'),
    IN start_date DATETIME,
    IN end_date DATETIME,
    OUT order_id INT UNSIGNED
)
BEGIN
    IF status IS NULL THEN
        SET status = 'pending';
    END IF;

    IF start_date IS NULL THEN
        SET start_date = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO crm.order (customer_id, status, start_date, end_date)
        VALUES (customer_id, status, start_date, end_date);
    SELECT LAST_INSERT_ID() INTO order_id;
END

CREATE PROCEDURE crm.add_customer_interaction (
    IN customer_id INT UNSIGNED,
    IN sales_rep_id INT UNSIGNED,
    IN date DATETIME,
    IN type ENUM('phone call', 'email', 'meeting'),
    IN details VARCHAR(200),
    IN outcome VARCHAR(200),
    OUT customer_interaction_id INT UNSIGNED
)
BEGIN
    IF date IS NULL THEN
        SET date = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO crm.customer_interaction (customer_id, sales_rep_id, date, type, details, outcome)
        VALUES (customer_id, sales_rep_id, date, type, details, outcome);
    SELECT LAST_INSERT_ID() INTO customer_interaction_id;
END

CREATE PROCEDURE crm.add_purchase (
    IN order_id INT UNSIGNED,
    IN product_id INT UNSIGNED,
    IN quantity INT UNSIGNED
)
BEGIN
    INSERT INTO crm.purchase (order_id, product_id, quantity)
        VALUES (order_id, product_id, quantity);
END

SET SQL_MODE=@OLD_SQL_MODE;

/*markdown
CREATE UNIQUE INDEX primary_key_idx ON my_table (col1, col2, ...)
*/