SELECT * FROM crm.person;
SELECT * FROM crm.customer;
SELECT * FROM crm.address;
SELECT * FROM crm.product_category;
SELECT * FROM crm.campaign;
SELECT * FROM crm.sales_rep;
SELECT * FROM crm.connection;
SELECT * FROM crm.product;
SELECT * FROM crm.order;
SELECT * FROM crm.customer_interaction;
SELECT * FROM crm.purchase;

SELECT
    crm.person.person_id AS wow,
    crm.person.first_name,
    crm.person.last_name,
    crm.person.email,
    crm.person.phone,
    crm.customer.date_of_birth,
    crm.address.street,
    crm.address.city,
    crm.address.state,
    crm.address.zip_code
FROM
crm.person
JOIN crm.customer
ON crm.person.person_id = crm.customer.person_id
JOIN crm.address
ON crm.customer.address_id = crm.address.address_id;

ALTER TABLE employees
DROP CONSTRAINT EMP_EMAIL_UK;

SELECT * FROM employees;
SELECT * FROM employees WHERE `DEPARTMENT_ID` = 80 AND `COMMISSION_PCT` < .20;

UPDATE employees e RIGHT JOIN departments d ON e.`DEPARTMENT_ID` = d.`DEPARTMENT_ID`
SET e.`EMAIL` = 'not available', e.`COMMISSION_PCT` = 0.10
WHERE UPDATE employees e RIGHT JOIN departments d ON e.`DEPARTMENT_ID` = d.`DEPARTMENT_ID`
SET e.`EMAIL` = 'not available', e.`COMMISSION_PCT` = 0.10
WHERE d.`DEPARTMENT_NAME` = 'Accounting';
SELECT 
    e.`EMPLOYEE_ID`, 
    d.`DEPARTMENT_ID`, 
    d.`DEPARTMENT_NAME`, 
    e.`EMAIL` 
FROM 
    employees e
RIGHT JOIN 
    departments d ON e.`DEPARTMENT_ID` = d.`DEPARTMENT_ID`
WHERE 
    d.`DEPARTMENT_NAME` = 'Accounting';

UPDATE employees
SET `SALARY`=
    CASE `DEPARTMENT_ID`
        WHEN 40 THEN `SALARY` * 1.25
        WHEN 90 THEN `SALARY` * 1.15
        WHEN 110 THEN `SALARY` * 1.10
    END
WHERE `DEPARTMENT_ID` IN (40, 90, 110);

SELECT MIN(`SALARY`), MAX(`SALARY`) FROM employees WHERE `JOB_ID` = 'PU_CLERK';
SELECT `EMPLOYEE_ID`, `SALARY`, `COMMISSION_PCT` FROM employees WHERE `JOB_ID` = 'PU_CLERK' ORDER BY `SALARY` ASC;

UPDATE employees
SET `SALARY` =
    CASE `SALARY`
        WHEN (SELECT MIN(`SALARY`) FROM employees WHERE `JOB_ID` = 'PU_CLERK')
            OR (SELECT MAX(`SALARY`) FROM employees WHERE `JOB_ID` = 'PU_CLERK') THEN `SALARY` + 200
        ELSE `SALARY` * 1.2
    END,
`COMMISSION_PCT` = `COMMISSION_PCT` + .1
WHERE `JOB_ID` = 'PU_CLERK';


DELETE FROM employees WHERE TRUE;

UPDATE employees e
SET e.`SALARY` = CASE
    WHEN (SELECT MIN(employees.`SALARY`) FROM employees WHERE employees.`JOB_ID` = 'PU_CLERK' UNION SELECT MAX(employees.`SALARY`) FROM employees WHERE employees.`JOB_ID` = 'PU_CLERK')
    THEN e.`SALARY` + 200
    ELSE e.`SALARY` * 1.2
    END,
    e.`COMMISSION_PCT` = e.`COMMISSION_PCT` + 0.1
WHERE `JOB_ID` = 'PU_CLERK';


(SELECT MIN(`SALARY`) FROM employees WHERE `JOB_ID` = 'PU_CLERK' UNION SELECT MAX(`SALARY`) FROM employees WHERE `JOB_ID` = 'PU_CLERK') 

SELECT COUNT(*) FROM employees;