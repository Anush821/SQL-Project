use retail_analysis;
select * from customer_profiles;
select * from product_inventory;
select * from sales_transaction;
/*   												SQL PROJECT –RETAIL ANALYSIS
														QUESTIONS SET 1 -EASY      								*/
/*  Question -1 */        
/* Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a 
separate table containing the unique values and remove the original table from the databases and replace the name 
of the new table with the original name. */

select transactionid,count(*)
from Sales_transaction
group by transactionid HAVING count(*)>1;

with removeduplicate as(
select *,
row_number() over(partition by transactionid order by transactionid) as rdp
from Sales_transaction 
)
select s.TransactionID,s.CustomerID,s.ProductID,s.QuantityPurchased,s.TransactionDate,s.Price
from removeduplicate r
join Sales_transaction s
on r.TransactionID =s.TransactionID
where rdp=1 limit 5000;

/* Quesdtion - 2 */

/* Problem statement
Write a query to identify the discrepancies in the price of the same product in "sales_transaction" 
and "product_inventory" tables. Also, update those discrepancies to match the price in both the tables.
*/

select s.TransactionID,s.price as TransactionPrice,
p.price as InventoryPrice 
from product_inventory p
join  sales_transaction s on s.productid=p.productid
where s.price !=p.price;

update sales_transaction st
set price =
(select p.price from product_inventory p where p.productid=st.productid)
where
st.productid in (select p.productid  from product_inventory p where st.price<>p.price);

select * from sales_transaction;

/* Quesdtion - 3 */

/*Problem statement
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
*/


select count(*) from customer_profiles where location is null;

update customer_profiles set Location = 'Unknown'
where location is NULL;

select * from customer_profiles;

/* Quesdtion - 4 */
/* 
Write a SQL query to clean the DATE column in the dataset.
	Steps:
Create a separate table and change the data type of the date column as it is in TEXT format and name it as you wish to.
Remove the original table from the database.
Change the name of the new table and replace it with the original name of the table.
*/

create table saletransaction as (select * from Sales_transaction);

alter table saletransaction modify column Transactiondate date;

drop table Sales_transaction;

alter table saletransaction rename Sales_transaction;

select *,Transactiondate as TransactionDate_updated from Sales_transaction;

/* Quesdtion - 5 */
/* Problem statement
Write a SQL query to summarize the total sales and quantities sold per product by the company.
(Here, the data has been already cleaned in the previous steps and from 
here we will be understanding the different types of data analysis from the given dataset.)
*/
select productID,
SUM(quantitypurchased) as TOTALUNITsSOLD,
SUM(quantitypurchased*price) as Totalsales 
from Sales_transaction
group by 1 
order by 3 desc;

/* Quesdtion - 6 */

/*Problem statement
Write a SQL query to count the number of transactions per customer to understand purchase frequency.
*/

select CustomerID,count(TransactionDate) as NumberOfTransactions
from Sales_transaction 
group by CustomerID
order by NumberOfTransactions desc;

/* Quesdtion - 7 */
/*Problem statement
Write a SQL query to evaluate the performance of the product categories based on the total sales 
which help us understand the product categories which needs to be promoted in the marketing campaigns.
*/

select p.category,
sum(s.QuantityPurchased) as TotalUnitsSold,
sum(s.QuantityPurchased*p.Price) as TotalSales
from Sales_transaction s
join
product_inventory p  on
s.ProductID=P.ProductID
group by p.category order by TotalSales desc;

/* Quesdtion - 8 */
/*Problem statement
Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. This will help the
company to identify the High sales products which needs to be focused to increase the revenue of the company.
*/
select ProductID ,
    Sum(QuantityPurchased*Price)  as totalrevenue
    from Sales_transaction 
    group by productId order by totalrevenue desc limit 10;

/* 								QUESTIONS SET 2 -MODERATE						*/

/* Quesdtion - 2.1 */
/* Problem statement
Write a SQL query to find the ten products with the least amount of units sold from 
the sales transactions, provided that at least one unit was sold for those products.
*/
select ProductID,sum(QuantityPurchased) as TotalUnitsSold
from Sales_transaction
group by productID
having sum(QuantityPurchased)>0
order by TotalUnitsSold asc limit 10;

/* Quesdtion - 2.2 */
/*Problem statement
Write a SQL query to identify the sales trend to understand the revenue pattern of the company.
*/
select TransactionDate as DATETRANS,count(transactiondate) as Transaction_count,
Sum(quantitypurchased) as TotalUnitssold,
Sum(quantitypurchased*price) as TotalSales
from sales_transaction
group by TransactionDate
order by DATETRANS desc;

/* Quesdtion - 2.3 */
/*Problem statement
Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.
*/
with monthtran as (
    select
		extract(month from transactionDate) as month,
		sum(QuantityPurchased*Price) as total_sales
		from sales_transaction
		group by month)

select month,total_sales,
Lag(total_sales) over(order by month ) as previous_month_sales,
((total_sales-Lag(total_sales) over(order by month))/Lag(total_sales) over(order by month))*100 
as mom_growth_percentage
from monthtran
order by  month;
/* Quesdtion - 2.4 */
/*Problem statement
Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side 
and will help us understand the customers who are the high frequency purchase customers in the company.
*/
select customerID,
count(Transactiondate) as NumberOfTransactions,
Sum(quantitypurchased*price) as Totalspent
from sales_transaction
group by customerID
having NumberOfTransactions>10 and Totalspent >1000
order by Totalspent desc;

/*                                   QUESTIONS SET 3 -ADVANCE                                         */
/* Quesdtion - 3.1 */
/* Problem statement
Write a SQL query that describes the total number of purchases made by each 
customer against each productID to understand the repeat customers in the company.
*/
select CustomerID,ProductID,
count(quantitypurchased) as TimesPurchased
from sales_transaction
group by CustomerID,ProductID
having TimesPurchased>1
order by TimesPurchased desc;
/* Quesdtion - 3.2 */
/*Problem statement
Write a SQL query that describes the duration between the first and 
the last purchase of the customer in that particular company to understand the loyalty of the customer.
*/
desc Sales_transaction;
select customerID,
min(transactiondate) as firstpurchase,
max(transactiondate) as lastpurchase,
datediff(max(transactiondate),min(transactiondate)) as DaysBetweenPurchases
from Sales_transaction
group by customerID
having datediff(max(transactiondate),min(transactiondate))>0
order by DaysBetweenPurchases desc;
/* Quesdtion - 3.3 */
/*
Write a SQL query that segments customers based on the total quantity of products they have purchased. Also, count the 
number of customers in each segment which will help us target a particular segment for marketing.
*/

create table Customer_segments as
(
	   select customerid,
		CASE
			WHEN total_quantity >30 then 'High'
			WHEN total_quantity between 10 and 30 THEN 'Med'
			WHEN total_quantity between 1 and 10 THEN 'Low'
		END AS CustomerSegment
		from 
			(
				select s.customerid,sum(s.quantitypurchased) as total_quantity
				from customer_profiles c 
				join sales_transaction s 
				on c.CustomerID=s.CustomerID
				group by s.CustomerID
			) as Customersegments
);

select Customersegment,count(*) from Customer_segments
group by Customersegment
order by 2 desc;


















