DROP DATABASE IF EXISTS crm;

DROP TABLE IF EXISTS purchase;

DROP TABLE IF EXISTS customer_interaction;

DROP TABLE IF EXISTS `order`;

DROP TABLE IF EXISTS product;

DROP TABLE IF EXISTS sales_rep;

DROP TABLE IF EXISTS connection;

DROP TABLE IF EXISTS customer;

DROP TABLE IF EXISTS campaign;

DROP TABLE IF EXISTS product_category;

DROP TABLE IF EXISTS address;

DROP TABLE IF EXISTS person;

DROP FUNCTION IF EXISTS crm.has_person;
DROP PROCEDURE IF EXISTS crm.add_person;
DROP PROCEDURE IF EXISTS crm.add_customer;
DROP PROCEDURE IF EXISTS crm.add_address;
DROP PROCEDURE IF EXISTS crm.add_product_category;
DROP PROCEDURE IF EXISTS crm.add_campaign;
DROP PROCEDURE IF EXISTS crm.add_sales_rep;
DROP PROCEDURE IF EXISTS crm.add_connection;
DROP PROCEDURE IF EXISTS crm.add_product;
DROP PROCEDURE IF EXISTS crm.add_order;
DROP PROCEDURE IF EXISTS crm.add_customer_interaction;
DROP PROCEDURE IF EXISTS crm.add_purchase;

DELETE FROM person WHERE TRUE;
DELETE FROM customer WHERE TRUE;
DELETE FROM address  WHERE TRUE;
DELETE FROM product_category  WHERE TRUE;
DELETE FROM campaign  WHERE TRUE;
DELETE FROM connection WHERE TRUE;
DELETE FROM crm.product WHERE TRUE;
DELETE FROM crm.order WHERE TRUE;
DELETE FROM crm.customer_interaction WHERE TRUE;
DELETE FROM crm.purchase WHERE TRUE;