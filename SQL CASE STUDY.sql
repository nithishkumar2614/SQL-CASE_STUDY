--1. List all customers

select *from customer

--2. List the first name, last name, and city of all customers

select firstname,lastname,city from customer

--3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering

select*from customer
where country = 'Sweden'


--4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.

DROP TABLE copy_of_supplier
select* into copy_of_supplier from supplier
update copy_of_supplier
set
city = 'sydney'
where companyname like 'P%'

--5. Create a copy of Products table and Delete all products with unit price higher than $50.

select* into copy_of_products from product
delete copy_of_products
where unitprice > $50

--6. List the number of customers in each country

select country,count(id) from customer
group by country

--7. List the number of customers in each country sorted high to low

select country,count(id) from customer
group by country
order by  count(id) desc

--8. List the total amount for items ordered by each customer

select customerid ,sum(totalamount) from [order]
group by customerid

--9. List the number of customers in each country. Only include countries with more than 10
--customers.

select country,count(id) from customer
group by country 
having count(id)>10

--10. List the number of customers in each country, except the USA, sorted high to low. Only
--include countries with 9 or more customers.

select country,count(id) from customer
where country != 'usa'
group by country
having count(id)>=9
order by count(id) desc

--11. List all customers whose first name or last name contains "ill".

select * from customer
where firstname like '%ill%'or lastname like '%ill%'

--12. List all customers whose average of their total order amount is between $1000 and
--$1200.Limit your output to 5 results.

select  top 5 customerid,avg(totalamount)from [order]
group by customerid
having avg(totalamount) between $1000 and $1200


--13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then
--by company name in reverse order.

select *from supplier
where country in ('usa','japan','germany')
order by country asc ,companyname desc

--14. Show all orders, sorted by total amount (the largest amount first), within each year.

select * from [order]
order by  year(orderdate) asc ,totalamount desc

--15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to
--discontinue products over $25. Write a query to relfelct this. Do this in the copy of the Product
--table. DO NOT perform the update operation in the Product table.

update copy_of_products
set
isdiscontinued = 1
where unitprice >$25

--16. List top 10 most expensive products

select top 10 * from product
order by unitprice desc

--17. Get all but the 10 most expensive products sorted by price

select * from product
order by unitprice desc
offset 10 rows

--18. Get the 10th to 15th most expensive products sorted by price

select*from product
order by unitprice desc
offset 9 rows
fetch next 6 rows only

--19. Write a query to get the number of supplier countries. Do not count duplicate values.

select country from supplier
group by country
                    [or]
select count(distinct country),country from supplier
group by country

--20. Find the total sales cost in each month of the year 2013.

select month(orderdate),sum(totalamount) [total sales] from [order]
where year(orderdate) = 2013
group by month(orderdate)

--21. List all products with names that start with 'Ca'.

select*from product
where productname like 'ca%'

--22. List all products that start with 'Cha' or 'Chan' and have one more character.

select*from product
where productname like 'cha_' or productname like 'chan_'

--23. Your manager notices there are some suppliers without fax numbers. He seeks your help to
--get a list of suppliers with remark as "No fax number" for suppliers who do not have fax
--numbers (fax numbers might be null or blank).Also, Fax number should be displayed for
--customer with fax numbers.

select id,companyname,contactname,city,country,phone,  isnull(fax,'no fax number')[fax] from supplier

OR

update copy_of_supplier
set 
fax ='No fax number'
where
fax is null

select*from copy_of_supplier

--24. List all orders, their orderDates with product names, quantities, and prices.

SELECT O.*,P.PRODUCTNAME,OI.Quantity,P.UnitPrice FROM[ORDER] O
 INNER JOIN ORDERITEM OI ON O.ID=OI.ORDERID
 INNER JOIN PRODUCT P ON P.ID=OI.ProductId

 --25. List all customers who have not placed any Orders.

 SELECT ID FROM CUSTOMER
 EXCEPT
 SELECT CUSTOMERID FROM [ORDER]

--26. List suppliers that have no customers in their country, and customers that have no suppliers
--in their country, and customers and suppliers that are from the same country.
select c.FirstName,
       c.lastname,
	   c.Country[Customercountry],
	   s.country[suppliercountry],
	   s.companyname
from customer c
 full join Supplier s on c.country=S.Country

-- 27. Match customers that are from the same city and country. That is you are asked to give a list
--of customers that are from same country and city. Display firstname, lastname, city and
--coutntry of such customers.

select
       c1.firstname[firstname1],
       c1.lastname[lastname1],
	   c2.firstname[firstname2],
	   c2.LastName[lastname2],
	   c1.city,
	   c1.country

from customer c1
 full join customer c2 on c1.country=c2.Country and c1.city=c2.city and c1.id!=c2.id


-- 28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a
--supplier and 'Customer' if he is a customer accordingly. Also, do not display firstname and
--lastname as twoi fields; Display Full name of customer or supplier.

select'supplier'[type],ContactName,city,Country,phone from supplier
union
select'customer'[type],concat(firstname,' ',lastname)[ContactName],city,country,phone from customer

--29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40).
--Update this city column using the city info in customers table.

select *into copy_of_orders from [order]

alter table  copy_of_orders add  city varchar(40)

update copy_of_orders 
set copy_of_orders.city = c.city
from customer c
where copy_of_orders.customerid=c.id

select *from copy_of_orders

--30. Suppose you would like to see the last OrderID and the OrderDate for this last order that
--was shipped to 'Paris'. Along with that information, say you would also like to see the
--OrderDate for the last order shipped regardless of the Shipping City. In addition to this, you
--would also like to calculate the difference in days between these two OrderDates that you get.
--Write a single query which performs this.
--(Hint: make use of max (columnname) function to get the last order date and the output is a
--single row output.)

select
   (select top 1 id from [order] order by orderdate desc) [LastOrder],
(select max(orderdate) from[order] where customerid in(select id from customer where city='paris'))[LastParisOrderDate],
 
 (select max(orderdate) from[order]) [LastOrderDate],

 datediff
 (day,
 (select max(orderdate) from[order] where customerid in(select id from customer where city='paris')),
           (select max(orderdate) from[order])) 




--  31. Find those customer countries who do not have suppliers. This might help you provide
--better delivery time to customers by adding suppliers to these countires. Use SubQueries.

select distinct country from customer
where country not in (
   select country from supplier);
         [or]
select country from customer
except
select country from supplier

--32. Suppose a company would like to do some targeted marketing where it would contact
--customers in the country with the fewest number of orders. It is hoped that this targeted
--marketing will increase the overall sales in the targeted country. You are asked to write a query
--to get all details of such customers from top 5 countries with fewest numbers of orders. Use
--Subqueries.
select c.* from customer c
where c.country in(
select top 5
country from customer c
   inner join [order] o on c.id= o.customerid
   group by country
   order by count(o.ordernumber) asc
   )

   select c.* from customer c
   select* from [order]

--   33. Let's say you want report of all distinct "OrderIDs" where the customer did not purchase
--more than 10% of the average quantity sold for a given product. This way you could review
--these orders, and possibly contact the customers, to help determine if there was a reason for
--the low quantity order. Write a query to report such orderIDs.
select orderid from orderitem oi
inner join (
select productid ,avg(quantity)[Average Quantity Sold ] from orderitem
group by productid)  s1 on oi.ProductId=s1.ProductId
where Quantity< 0.1 * [Average Quantity Sold]

--34. Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The
--total order item amount for 1 order for a customer is calculated using the formula UnitPrice *
--Quantity * (1 - Discount). DO NOT consider the total amount column from 'Order' table to
--calculate the total orderItem for a customer.

select
  customerid,sum(unitprice*quantity*(1-discount))[totalamount]from orderitem oi
  inner join [Order] o on oi.orderid=o.Id
  where year(orderdate) = 2013
  group by customerid
  having sum(unitprice*quantity*(1-discount))>7500


--  35. Display the top two customers, based on the total dollar amount associated with their
--orders, per country. The dollar amount is calculated as OI.unitprice * OI.Quantity * (1 -
--OI.Discount). You might want to perform a query like this so you can reward these customers,
--since they buy the most per country.
--Please note: if you receive the error message for this question "This type of correlated subquery
--pattern is not supported yet", that is totally fine.



 with cte as          (select distinct c.*,sum(totalamount) over (partition by customerid)[Total Sales by Customer] from customer c
           inner join [order] o on c.id=o.CustomerId) 

	select *
	from(
	       select* , rank()over(partition by country order by [Total Sales by Customer] desc)[rankbycountry]
		   from cte)t1
		   where t1.[rankbycountry]>=2







  --36. Create a View of Products whose unit price is above average Price.
  create view view_of_products as(
  select * from product
  where unitprice>(select avg(unitprice) from product)
 )
 
 select *from view_of_products


 ---37. Write a store procedure that performs the following action: 
---Check if Product_copy table (this is a copy of Product table) is present. If table exists, the 
--procedure should drop this table first and recreated. 
--Add a column Supplier_name in this copy table. Update this column with that of 
--'CompanyName' column from Supplier tab 

create procedure jacksjeje as
 drop table copy_of_products
 select *into copy_of_products from product 
 alter table copy_of_products add company_name varchar(20)
 
 update copy_of_products
 set copy_of_products.company_name=s.companyname
 from supplier s
 where copy_of_products.SupplierId=s.Id

 exec  jacksjeje
 select* from copy_of_products











