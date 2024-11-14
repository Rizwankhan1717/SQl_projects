-- Case Study
-- 1) Create a Sales Order dataset

-- Table 01 

create table products
(
	id				    int generated always as identity primary key,
	name			    varchar(100),
	price			    float,
	release_date 	    date
);
insert into products 
values(default,'iPhone 15', 800, to_date('22-08-2023','dd-mm-yyyy'));
insert into products 
values(default,'Macbook Pro', 2100, to_date('12-10-2022','dd-mm-yyyy'));
insert into products 
values(default,'Apple Watch 9', 550, to_date('04-09-2022','dd-mm-yyyy'));
insert into products 
values(default,'iPad', 400, to_date('25-08-2020','dd-mm-yyyy'));
insert into products 
values(default,'AirPods', 420, to_date('30-03-2024','dd-mm-yyyy'));


-- Table 02

create table customers
(
    id         int generated always as identity primary key,
    name       varchar(100),
    email      varchar(30)
);
insert into customers values(default,'Meghan Harley', 'mharley@demo.com');
insert into customers values(default,'Rosa Chan', 'rchan@demo.com');
insert into customers values(default,'Logan Short', 'lshort@demo.com');
insert into customers values(default,'Zaria Duke', 'zduke@demo.com');


-- Table 03

create table employees
(
    id         int generated always as identity primary key,
    name       varchar(100)
);
insert into employees values(default,'Nina Kumari');
insert into employees values(default,'Abrar Khan');
insert into employees values(default,'Irene Costa');


-- Table 04

create table sales_order
(
	order_id		  int generated always as identity primary key,
	order_date	  date,
	quantity		  int,
	prod_id			  int references products(id),
	status			  varchar(20),
	customer_id		int references customers(id),
	emp_id			  int,
	constraint fk_so_emp foreign key (emp_id) references employees(id)
);
insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),2,1,'Completed',1,1);
insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),3,1,'Pending',2,2);
insert into sales_order 
values(default,to_date('02-01-2024','dd-mm-yyyy'),3,2,'Completed',3,2);
insert into sales_order 
values(default,to_date('03-01-2024','dd-mm-yyyy'),3,3,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,1,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,3,'completed',2,1);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,2,'On Hold',2,1);
insert into sales_order 
values(default,to_date('05-01-2024','dd-mm-yyyy'),4,2,'Rejected',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),5,5,'Completed',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),1,1,'Cancelled',1,1);



SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM sales_order;


-- Problem Statement
-- 1. Identify the total no of products sold

select sum(quantity) as Total_sold_products
from sales_order;


-- 2. Other than Completed, display the available delivery status's

Select status
from sales_order 
where status != 'Completed';        -- <>

Select status
from sales_order 
where status not in ('Completed', 'completed');  -- check multiple value


-- for unique values
Select distinct status
from sales_order 
where status in ('Completed', 'completed');


-- aslo we can use function to convert the matching value
Select status
from sales_order 
where lower(status) != 'completed'; 



-- 3) Display the order id, order_date and product_name for all the completed orders.

select order_id,order_date,name
from sales_order s
inner join products p 
on s.prod_id = p.id
where lower(status) != 'completed'; 


-- 4) Sort the above query to show the earliest orders at the top. Also, 
--    display the customer who purchased these orders.

select order_id,
order_date,
p.name as product_name,
c.name as customer_name
from sales_order s
inner join products p on s.prod_id = p.id
inner join customers c on s.customer_id = c.id
where lower(s.status) = 'completed' 
order by order_date asc;


-- 5) Display the total no of orders corresponding to each delivery status
select count(*) as total_order, status
from sales_order
group by status;


-- 6. How many orders are still not completed for orders purchasing more than 1 item?
select count(*) as not_completed
from sales_order
where quantity > 1 and lower(status) <> 'completed';


-- 7. Find the total number of orders corresponding to each delivery status 
--    by ignoring the case in the delivery status. 
--    The status with highest no of orders should be at the top.


-- 1) first approch
select count(*) as total_order, updated_status
from (Select status,
		case when status = 'completed' then 'Completed'
	 	 else status
	  end as updated_status
from sales_order) as s
group by updated_status
order by total_order desc;

-- 2) second approch
select  lower(status), count(*) as total_order
from sales_order
group by lower(status)
order by total_order desc;


-- 8) Write a query to identify the total products purchased by each customer 

select 
sum(s.quantity),
c.name as customer_name
from sales_order s 
inner join customers c 
on s.customer_id = c.id 
group by c.name

-- 9) Display the total sales and average sales done for each day. 
select order_date,
sum(quantity * p.price) as total_sales,
avg(quantity * p.price) as Avg_sales
from sales_order s 
inner join products p 
on s.prod_id = p.id
group by order_date 
order by order_date;

-- 10. Display the customer name, employee name, and 
--     total sale amount of all orders which are either on hold or pending.

select
sum(quantity * p.price) as total_sales,
c.name as customer_name,
e.name as emp_name
from sales_order s
join customers c on s.customer_id = c.id
join employees e on s.emp_id = e.id
join products p on s.prod_id = p.id
where s.status in ('On Hold','Pending')
group by c.name, e.name;


-- 11) Fetch all the orders which were neither completed/pending or were handled by the employee Abrar. 
--     Display employee name and all details of order.

select e.name,s.*
from sales_order s
join employees e 
on e.id = s.emp_id
where lower(status) not in ('completed', 'pending')
or e.name like '%Abrar%';


--  12. Fetch the orders which cost more than 2000 but did not include the MacBook Pro. 
--      Print the total sale amount as well.

select s.*, p.name,
(quantity * price) as total_cost
from sales_order s 
join products p 
on p.id = s.prod_id
where (quantity * price) > 2000 and p.name not like '%Macbook Pro%';



-- 13) Identify the customers who have not purchased any product yet

-- 1) first approch
select *
from customers
where id not in (select distinct customer_id
from sales_order);


-- 2) Second approch
select c.*
from customers c 
left join sales_order s 
on s.customer_id = c.id
where s.order_id is null;



-- 14. Write a query to identify the total products purchased by each customer. 
--     Return all customers irrespective of whether they have made a purchase or not. 
--     Sort the result with the highest no of orders at the top.

select c.name , coalesce(sum(quantity), 0) as tot_prod_purchased
from sales_order s
right join customers c on c.id = s.customer_id
group by c.name
order by tot_prod_purchased desc;



-- 15. Corresponding to each employee, display the total sales they made of all the completed orders.
--     Display total sales as 0 if an employee made no sales yet.

select e.name as employee, coalesce(sum(p.price * s.quantity),0) as total_sale
from sales_order s
join products p on p.id = s.prod_id
right join employees e on e.id = s.emp_id and lower(s.status) = 'completed'
group by e.name
order by total_sale desc;



-- 16) Re-write the above query to display the total sales made by each employee corresponding to each customer. 
--     If an employee has not served a customer yet then display "-" under the customer.

select e.name as employee, 
coalesce(c.name, '-') as customer, 
coalesce(sum(p.price * s.quantity),0) as total_sale
from sales_order s
join products p on p.id = s.prod_id
join customers c on c.id = s.customer_id
right join employees e on e.id = s.emp_id
and lower(s.status) = 'completed'
group by e.name, c.name
order by total_sale desc;


-- 17) Identify employees who have served more than 2 customers.

select e.name, count(distinct c.name) as total_customers
from sales_order s
join employees e on e.id = s.emp_id
join customers c on c.id = s.customer_id
group by e.name
having count(distinct c.name) > 2;

-- 18) Identify the customers who have purchased more than 5 products

select c.name as customer, sum(quantity) as total_products_purchased
from sales_order s
join customers c on c.id = s.customer_id
group by c.name
having sum(quantity) > 5;


-- 19) Identify customers whose average purchase cost exceeds the average sale of all the orders.
select c.name as customer, avg(quantity * p.price)
from sales_order s
join customers c on c.id = s.customer_id
join products p on p.id = s.prod_id
group by c.name
having avg(quantity * p.price) > (select avg(quantity * p.price)
from sales_order s
join products p on p.id = s.prod_id);


