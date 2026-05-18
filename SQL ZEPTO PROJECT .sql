
create database zepto

use zepto

select * from zepto_data

select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME like 'zepto_data'

-- DATA EXPLORATION

select COUNT(*) [Number of records] from zepto_data

select top 10 * from zepto_data

-- CHECKING FOR THE NULL VALUES PRESENT IN THE TABLE

select * from zepto_data
where Category is null
or
Product_Name is null
or
MRP is null
or
Discount_Percent is null
or
Available_Quantity is null
or
Discounted_Selling_Price is null
or
Weight_In_Gms is null
or
Out_of_Stock is null
or
Quantity is null

-- GLAD THAT THIS DATASET DOESN'T CONTAIN ANY NULL VALUES

/*
LET'S EXPLORE THE DIFFERENT PRODUCT CATEGORIES (UNIQUE ONES) 
IN THIS TABLE
*/

select distinct Category from zepto_data
order by Category

select COUNT(distinct Category) [Number of categories] from zepto_data

-- CHECK WHETHER THE PRODUCT CATEGORIES 
-- HAS OUT OF STOCK IN ANY OF THE PRODUCT

select Out_of_Stock,COUNT(Serial_No) [Stock Availability] 
from zepto_data group by Out_of_Stock

-- CHECK THE PRODUCT NAME WHETHER ITS PRESENT MULTIPLE TIMES OR NOT

select distinct Product_Name,COUNT(Serial_No) [No of times purchased] 
from zepto_data
group by Product_Name
having COUNT(Serial_No)>1
order by COUNT(Serial_No) desc

-- DATA CLEANING

select Product_Name,MRP,Discounted_Selling_Price 
from zepto_data
where MRP = 0 and Discounted_Selling_Price = 0

delete from zepto_data
where MRP = 0 and Discounted_Selling_Price = 0

select COUNT(*) [Number of records] from zepto_data

-- CONVERTING PAISE INTO RUPEES

update zepto_data
set MRP = MRP / 100 , 
Discounted_Selling_Price = Discounted_Selling_Price / 100

select MRP,Discounted_Selling_Price from zepto_data

/*
Everything is fine but when i look at the MRP and
discount_selling_price column it doesn't look like a price column
because it just displaced numbers. so i thought it will look
better when it has rupees with paise (that is 2 decimal digits)
when i look INFORMATION SCHEMA i realised that i have forget to
change the data type for the MRP and discount_selling_price 
so i decide to change the those data type.
*/

alter table zepto_data alter column MRP decimal(8,2)

alter table zepto_data alter column Discounted_Selling_Price decimal(8,2)

select MRP,Discounted_Selling_Price from zepto_data

-- Now its looking better with decimal digits

-- Now getting into solving the business question

--1.) Find the top 10 best-value products based on discount percentage

select distinct top 10 Product_Name,MRP,Discount_Percent from zepto_data
order by Discount_Percent desc

--2.) What are the products with high-MRP that are currently out of stock

select Product_Name,MRP,Out_of_Stock from zepto_data 
where Out_of_Stock = 'true' and MRP > (select AVG(MRP) from zepto_data)
order by MRP desc

--3.) Calculate potential revenue for each product category

select Category,SUM(Discounted_Selling_Price * Available_Quantity) [Total expected revenue] 
from zepto_data
group by Category
order by [Total expected revenue] desc

--4.) Find all the products where MRP is greater than 500 
-- and discount is less than 10%.

select distinct Product_Name,MRP,Discount_Percent from zepto_data 
where MRP > 500 and Discount_Percent < 10
order by MRP desc

--5.) Identify the top 5 categories offering the highest average discounts percentage

select distinct top 5 Category,cast(AVG(Discount_Percent) as decimal(8,2)) [Avg discount percentage] 
from zepto_data
group by Category
order by [Avg discount percentage] desc

--6.) Find the price per gram for products above 100g and sort by best value.

select distinct Product_Name,Weight_In_Gms,Discounted_Selling_Price,
CAST(Discounted_Selling_Price/Weight_In_Gms as decimal(10,2)) [price per gram]
from zepto_data
where Weight_In_Gms > 100
order by Weight_In_Gms

--7.) Group the products into categories like Low, Medium, and Bulk.

select distinct Product_Name,Weight_In_Gms,
case
	when Weight_In_Gms <= 1000 then 'Low'
	when Weight_In_Gms <= 3000 then 'Medium'
	else 'Bulk'
end [Weight in category]
from zepto_data

--8.) what is the total inventory weight per product category

select distinct Category,SUM(Available_Quantity * Weight_In_Gms) [Total Inventory weight] 
from zepto_data
group by Category
order by [Total Inventory weight]

/*
The above query throws error because output of total inventory weight gives larger
number but the data type of those columns involved in calculation of the total inventory 
weight doesn't support the output because i had given small int for those two columns
so i had changed the data type from small int to int now it supporting.
*/

alter table zepto_data alter column Available_Quantity int

alter table zepto_data alter column Weight_In_Gms int