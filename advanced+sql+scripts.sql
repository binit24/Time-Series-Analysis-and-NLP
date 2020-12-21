--Analysing user_objects and all_objects views
select * from user_objects; 
select * from cat; 
select * from user_catalog; 
select * from all_objects; 
select * from dba_objects; 

--Searching in tables (user_tables)
select * from user_tables; 
select * from all_tables;
select * from dba_tables; 
select * from user_tables where table_name = 'LOCATIONS';
select * from tabs;

--Querying and searching columns of tables (USER_TAB_COLUMNS)
select * from user_tab_columns;
select * from cols;
select column_name,data_type,data_length,nullable,data_default,num_nulls,avg_col_len,num_distinct from user_tab_columns
where table_name = 'EMPLOYEES';

--Retrieving constraints of a table
select * from USER_CONSTRAINTS;
select owner,table_name,constraint_name,constraint_type,search_condition,r_constraint_name,delete_rule,status,index_name 
from user_constraints;

--Finding columns bound to a constraint
select * from user_cons_columns;
select * from user_cons_columns where table_name = 'EMPLOYEES';

--Finding related tables using table comments
Select * from user_tab_comments;
Select * from user_col_comments;
select * from user_tab_comments where upper(comments) like '%EMPLOYEES%';
select * from user_COL_comments where upper(comments) like '%EMPLOYEES%';

--Creating Sequences
create sequence employee_seq
start with 200
increment by 3
maxvalue 9999
cache 50
nocycle 
order;
drop sequence employee_seq;

---Modifying sequences
ALter sequence employee_seq
increment by 2
maxvalue 500
nocache
nocycle
noorder;

--Dropping a sequence
drop sequence employee_seq;

----Using sequence
select employee_seq.currval from dual;
select employee_seq.nextval from dual;

insert into employees (employee_id,first_name,last_name,email,hire_date,salary,job_id)
values (employee_seq.nextval,'Alex','Earnst','ALEXIS',sysdate,'2500','IT_PROG');

DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = EMPLOYEE_SEQ.CURRVAL;
DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = 221;

---using sequence as default value
create table temp (t1 number default employee_seq.nextval not null, t2 varchar2(50));
insert into temp (t2) values ('alex');
select * from temp;
drop table temp;

---analyzing user sequences
desc user_sequences;
select * from user_sequences;
select * from user_sequences where sequence_name = 'EMPLOYEE_SEQ';

--Creating synonyms
create synonym sy for sys.user_objects;
select * from sy;
drop synonym sy;
--using synonyms
select * from sy where objeCt_type = 'TABLE';

--Analyzing user_synonyms
desc user_synonyms;

---CREATING INDEXES
select * from employees;
create unique index temp_idx
on employees (employee_id);

create unique index temp_idx
on employees (phone_number);

create bitmap index temp_idx
on employees (first_name,last_name);

CREATE TABLE employee_temp
(employee_id NUMBER(6) PRIMARY KEY USING INDEX
(CREATE INDEX temp_idx ON
employee_temp(employee_id)),
first_name VARCHAR2(20),
last_name VARCHAR2(25));
drop table employee_temp;
--Function-based indexes
Create index first_name_idx on employees (upper(first_name));
drop index first_name_idx;
select * from employees where UPPER(first_name) = 'ALEX'; 


--Multiple Indexes with the same set of colums
CREATE INDEX temp_idx
ON employees(first_name, last_name);

ALTER INDEX temp_idx INVISIBLE;

CREATE BITMAP INDEX temp_idx
ON employees(first_name, last_name);

--Removing indexes
drop index temp_idx;

--Analyzing user_indexes
select * from user_indexes;
select * from all_col_comments where table_name = 'USER_INDEXES';
select * from user_ind_columns where table_name = 'EMPLOYEES' ORDER BY INDEX_NAME;

--Creating views
CREATE VIEW empvw90 AS
  SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = 90;
SELECT * FROM EMPVW40;

CREATE VIEW empvw20 AS
  SELECT EMPLOYEE_ID,FIRST_NAME,LAST_NAME FROM EMPLOYEES WHERE DEPARTMENT_ID = 20;

CREATE VIEW empvw30 AS
  SELECT EMPLOYEE_ID EID,FIRST_NAME NAME,LAST_NAME SURNAME FROM EMPLOYEES WHERE DEPARTMENT_ID = 30;
  
CREATE VIEW EMPVW40 (EID,NAME,SURNAME,EMAIL) AS
SELECT EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL FROM EMPLOYEES
WHERE DEPARTMENT_ID = 40;

--Modifying Views
CREATE OR REPLACE VIEW EMPVW30 (EID,NAME,EMAIL,JOB_ID,PHONE) AS
  SELECT EMPLOYEE_ID,FIRST_NAME||' '||LAST_NAME,EMAIL,JOB_ID,PHONE_NUMBER FROM EMPLOYEES
  WHERE DEPARTMENT_ID = 30;

SELECT * FROM EMPVW30;
DROP VIEW EMPVW30;


--Performing DML Operations with views
create view empvw80 as 
select employee_id,first_name,last_name,email,hire_date,job_id,department_id from employees
where department_id = '80'
with check option;

insert into empvw80 values
(208,'Alex', 'Brown','ABROWN',sysdate,'IT_PROG',80);

insert into empvw80( employee_id,first_name,last_name,email,hire_date,job_id) values
(207,'Alex', 'Brown','ABROWN',sysdate,'IT_PROG');

delete from empvw80 where employee_id = 207;
select * from empvw80 where employee_id = 207;
delete from employees where employee_id = 207;

drop view empvw80;

--Preventing dml operations on a view
create view empvw80 as 
select employee_id,first_name,last_name,email,hire_date,job_id,department_id from employees
where department_id = '80'
with read only;

insert into empvw80 values
(208,'Alex', 'Brown','ABROWN',sysdate,'IT_PROG',80);


--Materialized Views
CREATE MATERIALIZED VIEW deparment_max_salaries_mv
BUILD IMMEDIATE 
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS 
	SELECT DEPARTMENT_ID,max(salary) FROM employees
	GROUP BY DEPARTMENT_ID
	ORDER BY DEPARTMENT_ID; 

CREATE MATERIALIZED VIEW LOG ON employees;
DROP MATERIALIZED VIEW LOG ON employees; 
drop materialized view deparment_max_salaries_mv;

--Fast Refresh
Create materialized view vw_sales_managers
build immediate 
refresh fast on commit
as SELECT * FROM employees
	WHERE job_id = 'SA_MAN';
  
SELECT * FROM vw_sales_managers;
insert into employees values (400,'Alex','Brown','abrown','111111111',sysdate,'SA_MAN',10000,NULL,102,60);
DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = 400;
SELECT * FROM vw_sales_managers;

---Refreshing Materialized V?ews 
CREATE MATERIALIZED VIEW vw_it_programmers
BUILD IMMEDIATE 
REFRESH FORCE
ENABLE QUERY REWRITE AS 
	SELECT * FROM employees
	WHERE job_id = 'IT_PROG'
	ORDER BY department_id;
--REFRESHING MANUALLY
EXECUTE DBMS_MVIEW.REFRESH('vw_it_programmers','F');
EXECUTE DBMS_SNAPSHOT.REFRESH('vw_it_programmers','c');
EXECUTE DBMS_MVIEW.REFRESH_ALL;

select * from employees where job_id = 'IT_PROG';
insert into employees values (333,'dfsadf','sdfsdf','asdf','34324',sysdate,'IT_PROG',4444,NULL,102,70);
SELECT * FROM vw_it_programmers;

DELETE FROM employees  WHERE EMPLOYEE_ID = 333;
DROP MATERIALIZED VIEW LOG  ON employees;
CREATE MATERIALIZED VIEW LOG ON employees;
DROP MATERIALIZED VIEW deparment_max_salaries_mv2;


---Scheduling Periodic Materialized View              
CREATE MATERIALIZED VIEW vw_sales_managers5
BUILD IMMEDIATE 
REFRESH FORCE
START WITH to_date('10-MAR-16','DD-MON-RR')
NEXT sysdate + 5 
	AS 
	SELECT * FROM employees
	WHERE job_id = 'SA_MAN'
	ORDER BY department_id;


--Retrieving data by using advanced subqueries
Select a.first_name,a.last_name,a.hire_date,a.job_id,b.department_name,b.city from empvw80 a join 
(select state_province,city,department_id,department_name from departments join locations using (location_id)) b
using (department_id);


--Multiple-column- subqueries
SELECT first_name, last_name,manager_id,department_id from employees 
where 
department_id in (select department_id from employees where UPPER(first_name) = 'LUIS')
and manager_id in (select manager_id from employees where UPPER(first_name) = 'LUIS')

/
--pairwise subquery
SELECT first_name, last_name,manager_id,department_id from employees 
where  (department_id, manager_id) in (select department_id, manager_id from employees where UPPER(first_name) = 'LUIS');
/
--scalar subquery
SELECT * FROM employees;
--Example 1
SELECT employee_id, first_name,last_name from EMPLOYEES 
where department_id = (select department_id from employees where upper(first_name) = 'LUIS');
--Example 2
SELECT employee_id, first_name,last_name, 
        (SELECT department_name FROM departments WHERE department_id = e.department_id ) AS department_name
        FROM EMPLOYEES e;
--Example 3 
--For example; we know San Francisco's Postal Code and we want to find if an employee works in San Francisco or not ....
SELECT employee_id, first_name,last_name, 
                (CASE WHEN location_id = (select location_id from locations where postal_code = '99236') then 'San Franscisco'
                ELSE 'Outside' END) COUNTRY FROM EMPLOYEES E NATURAL JOIN  DEPARTMENTS D;

--Correlated Subquery
SELECT employee_id, first_name,last_name,department_id, salary FROM employees a 
      where salary = (SELECT max(salary) from employees b where b.department_id = a.department_id );

--Exist Operator
SELECT employee_id, first_name,last_name,department_id FROM employees a 
WHERE EXISTS (SELECT 1,employee_id FROM EMPLOYEES WHERE MANAGER_ID = A.EMPLOYEE_ID);

--Not Exist Operator
SELECT employee_id, first_name,last_name,department_id FROM employees a 
WHERE NOT EXISTS (SELECT 1,employee_id FROM EMPLOYEES WHERE MANAGER_ID = A.EMPLOYEE_ID);

SELECT department_id, department_name FROM departments d 
WHERE not exists (select department_id from employees where department_id = d.department_id);

SELECT department_id, department_name FROM departments d 
WHERE department_id not in (select department_id from employees);

--Advanced Subqueries Using WITH Clause.
WITH MAX_SALARIES AS 
(
  SELECT MAX(SALARY) maximum_salary, trunc(AVG(salary)) average_salary, department_id 
    from EMPLOYEES GROUP BY DEPARTMENT_ID) 
SELECT employee_id, maximum_salary, average_salary, department_id FROM employees e 
NATURAL JOIN MAX_SALARIES;

--Using Recursive WITH Clause
WITH ALL_MANAGERS(Employee,Manager,Department) AS 
(
SELECT employee_id, manager_id, department_id from employees
UNION ALL
SELECT all_managers.employee, employees.manager_id,all_managers.department FROM all_managers, employees 
WHERE all_managers.manager = employees.employee_id
)

SELECT employee,manager,department from all_managers order by employee;
  
--Inseting data by using subquery as a target
select * from loc;
create table loc as select * from locations;
create table con as select * from countries;
drop table con;
INSERT INTO (SELECT l.location_id, l.city, l.country_id,c.country_name,c.region_id
FROM loc l
JOIN countries c
ON(l.country_id = c.country_id)
JOIN regions r on (r.region_id = c.region_id)
WHERE r.region_name = 'Europe')
VALUES (3300, 'Cardiff', 'UK','Hello Omer',1);

create table departments_temp as select * from departments;
select * from departments_TEMP;
select * from locations;

INSERT INTO 
  (SELECT d.department_id, d.department_name, d.manager_id, d.location_id
  FROM departments_temp d
  WHERE location_id = 
  (select location_id from locations where city = 'Oxford')
  WITH CHECK OPTION)
VALUES (300, 'Marketing', '145','2000');

--Correlated update
create table employees_temp as select * from employees;
select * from employees_temp;

update employees_temp t set
   (t.salary,t.commission_pct) = (
   select avg(salary),avg(e.commission_pct) from employees e join departments d on (e.department_id = d.department_id)
   where t.department_id = d.department_id
   group by d.department_id
   );

--Correlated delete
delete from employees_temp
where department_id in
  (select department_id from departments d natural join locations l
  where country_id = 'UK')
  
--Manipulating data
create table departments_temp as select * from departments;
select * from departments_temp;
alter table departments_temp modify (manager_id number(6) default 100);

insert into departments_temp (department_id,department_name,manager_id,location_id)
values (310,'Temp Department',default,2000);
update departments_temp set manager_id = default;

--Unconditional Insert All
create table employees_history as select employee_id,first_name,last_name,hire_date from employees where 1=2;
create table salary_history (employee_id number(6),year number(4),month number(2),salary number(8,2),commission_pct number(2,2));

insert all
  into employees_history values (employee_id,first_name,last_name,hire_date)
  into salary_history values (employee_id,extract (year from sysdate),extract (month from sysdate),salary,commission_pct)
  select * from employees where hire_date > sysdate-365;

select * from employees_history;
select * from salary_history;

drop table IT_PROGRAMMERS;

--Conditional Insert All
create table IT_PROGRAMMERS as select * from employees_history where 1=2;
create table LIVING_IN_US as select * from employees_history where 1=2;

INSERT ALL
  WHEN hire_date > sysdate-365 THEN
    INTO employees_history values (employee_id,first_name,last_name,hire_date)
    INTO salary_history values (employee_id,extract (year from sysdate),extract (month from sysdate),salary,commission_pct)
  WHEN job_id = 'IT_PROG' THEN
    INTO IT_PROGRAMMERS values (employee_id,first_name,last_name,hire_date)
  WHEN department_id in 
  (select department_id from departments where location_id in (select location_id from locations where country_id = 'US')) THEN
    INTO LIVING_IN_US values (employee_id,first_name,last_name,hire_date)
  SELECT * FROM EMPLOYEES;
  
select * from employees_history;
select * from salary_history;
SELECT * FROM IT_PROGRAMMERS;
DELETE FROM SALARY_HISTORY;
SELECT * FROM LIVING_IN_US;

--Conditional INSERT FIRST
CREATE TABLE LOW_SALARIES (EMPLOYEE_ID NUMBER(6),DEPARTMENT_ID NUMBER(6),SALARY NUMBER(8,2));
CREATE TABLE AVERAGE_SALARIES AS SELECT * FROM LOW_SALARIES;
CREATE TABLE HIGH_SALARIES AS SELECT * FROM LOW_SALARIES;
INSERT FIRST
  WHEN SALARY <5000 THEN
    INTO LOW_SALARIES VALUES (EMPLOYEE_ID,DEPARTMENT_ID,SALARY)
  WHEN SALARY BETWEEN 5000 AND 10000 THEN
    INTO AVERAGE_SALARIES VALUES (EMPLOYEE_ID,DEPARTMENT_ID,SALARY) 
  ELSE 
    INTO HIGH_SALARIES VALUES (EMPLOYEE_ID,DEPARTMENT_ID,SALARY)
  SELECT * FROM EMPLOYEES;

SELECT * FROM LOW_SALARIES;
SELECT * FROM AVERAGE_SALARIES;
SELECT * FROM HIGH_SALARIES;
DROP TABLE LOW_SALARIES;
DROP TABLE AVERAGE_SALARIES;
DROP TABLE HIGH_SALARIES;

--pivoting insert
create table job_salaries (year NUMBER(4),month NUMBER(2),IT_PROG NUMBER(8,2),SA_MAN NUMBER(8,2),ST_MAN NUMBER(8,2));
insert into job_salaries VALUES(2015,8,
(select sum(salary+NVL(SALARY*COMMISSION_PCT,0)) from employees where job_id = 'IT_PROG'),
(select sum(salary+NVL(SALARY*COMMISSION_PCT,0)) from employees where job_id = 'SA_MAN'),
(select sum(salary+NVL(SALARY*COMMISSION_PCT,0)) from employees where job_id = 'ST_MAN'));
SELECT * FROM JOB_SALARIES;

CREATE TABLE JOB_SAL (year NUMBER(4),month NUMBER(2),JOB_ID VARCHAR2(20),TOTAL_SALARY NUMBER(8,2));
insert all 
  into JOB_SAL VALUES (YEAR,MONTH,'IT_PROG',IT_PROG)
  into JOB_SAL VALUES (YEAR,MONTH,'SA_MAN',SA_MAN)
  into JOB_SAL VALUES (YEAR,MONTH,'ST_MAN',ST_MAN)
SELECT * FROM JOB_SALARIES;
SELECT * FROM JOB_SAL;
drop table JOB_SAL;

--Merge Operations
create table employees_copy as 
    select employee_id,first_name,last_name,department_id,job_id,salary from employees where job_id = 'IT_PROG';
SELECT * FROM EMPLOYEES_COPY;

MERGE INTO EMPLOYEES_COPY C USING (SELECT * FROM EMPLOYEES) E
ON (C.EMPLOYEE_ID = E.EMPLOYEE_ID)
WHEN MATCHED THEN
 UPDATE SET
  c.first_name= e.first_name,
  c.last_name = e.last_name,
  c.department_id = e.department_id,
  c.job_id = e.job_id,
  c.salary = e.salary
DELETE WHERE DEPARTMENT_ID IS NULL
WHEN NOT MATCHED THEN
INSERT VALUES (E.employee_id,E.first_name,E.last_name,E.department_id,E.job_id,E.salary);
SELECT * FROM EMPLOYEES_COPY;
SELECT * FROM EMPLOYEES;
drop table employees_copy;

---Flashback & purge
select * from recyclebin;
ALTER TABLE EMPLOYEES_COPY ENABLE ROW MOVEMENT; 
delete from employees_copy where salary > 5000;
commit;
select * from employees_copy;
flashback table employees_copy to timestamp sysdate-1/1440;
select dbms_flashback.get_system_change_number scn from dual;
FLASHBACK TABLE EMPLOYEES_COPY TO SCN 202381;
DROP TABLE EMPLOYEES_COPY PURGE;

--Tracking Changes
--1
drop table employees_copy;
--2
create table employees_copy as select * from employees;
select * from employees_copy ;
--3
update employees_copy set salary = 1500 
where employee_id = 100;
commit;
--4
SELECT * FROM employees_copy
WHERE employee_id= 100;
--5
SELECT * FROM employees_copy
AS OF sysdate - 
WHERE employee_id= 100;
--5.1
SELECT * FROM employees_copy
AS OF SCN 6167700
WHERE employee_id= 100;

--CAN RUN IN SQL PLUS
SELECT DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER FROM DUAL;
--6 VERSIONS

SELECT * FROM V$TRANSACTION;
-----------------------------------------
--Flashback Versions Query
SELECT * FROM employees_copy
WHERE employee_id= 100;

UPDATE employees_copy SET salary = 2700
WHERE employee_id = 100;
commit;

UPDATE employees_copy SET salary = 3600
WHERE employee_id = 100;
commit;


SELECT versions_starttime,versions_starttime, salary FROM employees_copy
VERSIONS BETWEEN SCN MINVALUE AND MAXVALUE
WHERE employee_id= 100;


SELECT * FROM employees_copy
AS OF SCN 6167700
WHERE employee_id= 100;


SELECT versions_starttime,versions_starttime, salary FROM employees_copy
VERSIONS  BETWEEN TIMESTAMP(sysdate - interval '13' minute)  AND sysdate
WHERE employee_id= 100;

--controlling schema objects
--adding constraint
alter table employees_temp add constraint
temp_cons unique (employee_id);
alter table employees_temp add constraint
temp_cons2 unique (employee_id,first_name);
alter table employees_temp add unique (phone_number);

alter table employees_temp modify job_id constraint
not_null_job not null;
alter table employees_temp modify first_name not null;

alter table employees_temp drop constraint temp_cons; 
alter table employees_temp drop constraint SYS_C0010501;

--on delete 
ALTER TABLE salary_history ADD CONSTRAINT sal_emp_fk
FOREIGN KEY (employee_id)
REFERENCES employees_temp(employee_id) ON DELETE CASCADE;

SELECT * FROM HIGH_SALARIES;
ALTER TABLE HIGH_SALARIES ADD CONSTRAINT hi_emp_fk
FOREIGN KEY (employee_id)
REFERENCES employees_temp(employee_id) ON DELETE SET NULL;

--cascading constraints
select * from all_constraints where table_name = 'EMPLOYEES_TEMP';
alter table departments_temp add constraint pk_dep_temp 
primary key (department_id );
ALTER TABLE employees_temp ADD CONSTRAINT emp_dp_man_fk
FOREIGN KEY (department_id)
REFERENCES departments_temp(department_id);

create table departments_temp as select * from departments;
select * from departments_temp;
alter table departments_temp drop column department_id cascade constraints;
drop table departments_temp;
create table departments_temp as select * from departments;

--renaming constraints
select * from all_constraints where table_name = 'EMPLOYEES_TEMP'; 
ALTER TABLE EMPLOYEES_TEMP RENAME CONSTRAINT SYS_C0010502 TO UQ_EMP_ID;
ALTER TABLE EMPLOYEES_TEMP RENAME CONSTRAINT UQ_EMP_ID TO SYS_C0010502;

--enabling and disabling constraints
alter table employees_temp drop constraint SYS_C0010502;
ALTER TABLE EMPLOYEES_TEMP add constraint pk_emp_temp 
primary key (employee_id);
ALTER TABLE EMPLOYEES_TEMP DISABLE CONSTRAINT SYS_C0010502;
ALTER TABLE EMPLOYEES_TEMP DISABLE CONSTRAINT SYS_C0010502 CASCADE;
SELECT * FROM HIGH_SALARIES;

ALTER TABLE EMPLOYEES_TEMP ENABLE CONSTRAINT SYS_C0010502; 
SELECT * FROM HIGH_SALARIES;

--Status of constraints
ALTER TABLE EMPLOYEES_TEMP DROP CONSTRAINT SYS_C0010502 CASCADE;
ALTER TABLE EMPLOYEES_TEMP add constraint pk_emp_temp 
primary key (employee_id);
ALTER TABLE EMPLOYEES_TEMP ENABLE NOVALIDATE PRIMARY KEY; 
ALTER TABLE EMPLOYEES_TEMP ENABLE NOVALIDATE CONSTRAINT EMP_UQ2; 
ALTER TABLE HIGH_SALARIES DISABLE NOVALIDATE CONSTRAINT HI_EMP_FK; 

--Deferring constraints
create table dep_temp as select * from departments;
ALTER TABLE DEP_TEMP
ADD CONSTRAINT dep_id_pk
PRIMARY KEY (department_id)
DEFERRABLE INITIALLY DEFERRED;
select * from dep_temp;
insert into DEP_TEMP VALUES (10,'Temp Department',200,1700);
commit;
SET CONSTRAINTS dep_id_pk IMMEDIATE;
ALTER SESSION SET CONSTRAINTS = IMMEDIATE;
insert into DEP_TEMP VALUES (10,'Temp Department',200,1700);

ALTER TABLE DEP_TEMP DROP CONSTRAINT dep_id_pk;

ALTER TABLE DEP_TEMP
ADD CONSTRAINT dep_id_pk
PRIMARY KEY (department_id)
NOT DEFERRABLE;

SET CONSTRAINTS dep_id_pk IMMEDIATE;
SET CONSTRAINTS dep_id_pk DEFERRED;

--Temporary tables
create global temporary table shopping_cart( id number, shopping_date date)
on commit delete rows;

insert into shopping_cart values(1,sysdate);
select * from shopping_cart;
commit;
select * from shopping_cart;
CREATE GLOBAL TEMPORARY TABLE sales_managers
ON COMMIT PRESERVE ROWS AS
SELECT * FROM employees
WHERE job_id = 'SA_MAN';

insert into sales_managers (employee_id,first_name,last_name,email,hire_date,job_id) values
('123','OMER','DAGASAN','oraclemaster@outlook.com',sysdate,'SA_MAN');
insert into shopping_cart values(1,sysdate);
select * from sales_managers;
commit;
select * from sales_managers;

--Privileges
select * from system_privilege_map;
select * from user_sys_privs;
select * from session_privs;

create user temp_user identified by 123;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO TEMP_USER;
DROP USER TEMP_USER;

-- ROLE
CREATE ROLE DEVELOPER;
GRANT CREATE TABLE, CREATE VIEW TO DEVELOPER;
GRANT DEVELOPER TO TEMP_USER;

---CHANGE PASSWORD
password;
ALTER USER HR IDENTIFIED BY HR;


--Hierarchical Retrieval
--1
SELECT employee_id, first_name,last_name, job_id, manager_id
FROM employees
START WITH employee_id = 102
CONNECT BY PRIOR employee_id = manager_id ;
--2
SELECT employee_id, first_name,last_name, job_id, manager_id
FROM employees
START WITH employee_id = 102
CONNECT BY PRIOR manager_id = employee_id ;

--Changing Priors position
SELECT employee_id, first_name,last_name, job_id, manager_id
FROM employees
START WITH employee_id = 102
CONNECT BY employee_id = PRIOR manager_id;
--- 
SELECT LEVEL, employee_id, first_name,last_name, job_id, manager_id
FROM employees where level = 2
START WITH employee_id = 101
CONNECT BY  manager_id = PRIOR employee_id ;


---Formatting Tree Structure with Using LEVEL and LPAD
SELECT LPAD(last_name, LENGTH(last_name)+(LEVEL*2)-2,'> ')
  AS employees_hierarchy
  FROM employees
START WITH employee_id =101
CONNECT BY PRIOR employee_id=manager_id;


--Pruning Branches of a Tree
SELECT employee_id,last_name,manager_id
  FROM employees where employee_id <> 108
START WITH employee_id =101
CONNECT BY PRIOR employee_id=manager_id;

--Pruning Branches of a Tree
SELECT employee_id,last_name,manager_id
  FROM employees 
START WITH employee_id =101
CONNECT BY PRIOR employee_id=manager_id
AND employee_id <> 108;

--Generating SQL Scripts
SELECT 'CREATE TABLE ' || table_name || '_backup ' || 'AS SELECT * FROM '
|| table_name AS 
"Backup Scripts" FROM user_tables;


SELECT 'CREATE TABLE ' || table_name || '_backup ' || 'AS SELECT * FROM '
|| table_name || ';'  AS 
"Backup Scripts" FROM user_tables;



SELECT 'DROP TABLE ' || table_name || ';' 
FROM user_tables WHERE table_name like '%_BACKUP%';

---------regular expressions-----------
--------------regexp_like-------------

SELECT first_name, last_name
FROM employees
WHERE REGEXP_LIKE (first_name, '^Ste(v|ph)en$');

ALTER TABLE employees_copy add constraint  number_format      
      CHECK ( REGEXP_LIKE ( phone_number, '^\d{3}.\d{3}.\d{4}$' ) ) novalidate;
      
 select * from     employees_copy where  REGEXP_LIKE ( phone_number, '^\d{3}.\d{3}.\d{4}$' );

