select * from sales

select column_name, IS_NULLABLE,DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'SALES'
/*
columns
	Row_ID
	Order_ID
	Order_Date
	Ship_Date
	Ship_Mode
	Customer_ID
	Customer_Name
	Segment
	Country
	City
	State
	Postal_Code
	Region
	Product_ID
	Category
	Sub_Category
	Product_Name
	Sales
*/
---------------
--Data Profiling
--***************
--Presence of Null Values

select
sum(case when Row_ID is null then 1 else 0 end) as Row_id_nulls,
sum(case when Order_ID is null then 1 else 0 end) as Order_ID_nulls,
sum(case when Order_Date is null then 1 else 0 end) as Order_Date_nulls,
sum(case when Ship_Date is null then 1 else 0 end) as Ship_Date_nulls,
sum(case when Ship_Mode is null then 1 else 0 end) as Ship_Mode_nulls,
sum(case when Customer_ID is null then 1 else 0 end) as Customer_ID_nulls,
sum(case when Customer_Name is null then 1 else 0 end) as Customer_Name_nulls,
sum(case when Segment is null then 1 else 0 end) as Segment_nulls,
sum(case when Country is null then 1 else 0 end) as Country_nulls,
sum(case when City is null then 1 else 0 end) as City_nulls,
sum(case when State is null then 1 else 0 end) as State_nulls,
sum(case when Postal_Code is null then 1 else 0 end) as Postal_Code_nulls,
sum(case when Region is null then 1 else 0 end) as Region_nulls,
sum(case when Product_ID is null then 1 else 0 end) as Product_ID_nulls,
sum(case when Category is null then 1 else 0 end) as Category_nulls,
sum(case when Sub_Category is null then 1 else 0 end) as Sub_Category_nulls,
sum(case when Product_Name is null then 1 else 0 end) as Product_Name_nulls,
sum(case when Sales is null then 1 else 0 end) as Sales_nulls
from sales

--11 Nulls in postal code
-----------------------------------------------------------
--Verify the Duplicate entries

select
count(*) as duplicates
from
(
select *,
ROW_NUMBER() over (Partition by ORDER_ID, Customer_ID, Product_ID order by ORDER_ID) as rw_num
from sales) a
where rw_num > 1

--There are no Duplicates
-------------------------------------------------------------------------------
--Date Range Analysis

select *,
DATEDIFF(YEAR,Minimum_date,Maximum_date) as Years,
DATEDIFF(QUARTER,Minimum_date,Maximum_date) as Quarter,
DATEDIFF(MONTH,Minimum_date,Maximum_date) as Month
from
(
select 
CAST(min(Order_Date) as DATE) as Minimum_date,
CAST(max(Order_Date) as DATE) as Maximum_date
from sales ) a
----------------------------------------------------------------------------
--Business Analysis Using SQL
--===========================
--Key Performance Indicators (KPI)

select 'Total Sales' as Metrics,ROUND(sum(Sales),0) as Metrics_Value from sales
union all
select 'Total Orders', COUNT(DISTINCT Order_ID) from sales
union all
select 'Total Customers', COUNT(DISTINCT Customer_ID) from sales
----------------------------------------------------------------
--1.Average Shipping Days

select
Ship_Mode,
AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) as AVG_Shipping_Days 
from sales
group by Ship_Mode
Order by AVG_Shipping_Days Desc
----------------------------------
--2.Total Sales and Contribution By Ship Mode

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Ship_Mode,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Ship_Mode) a
order by Total_Sales Desc
-------------------------------
--3.Total Orders By Ship Mode

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Ship_Mode,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Ship_Mode) a
order by Total_orders Desc
------------------------------------
--4.Total Sales and Contribution By Segment

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Segment,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Segment) a
order by Total_Sales Desc
---------------------------
--5.Total Orders By Segment

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Segment,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Segment) a
order by Total_orders Desc
--------------------------
--6.Total Sales and Contribution By Region

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Region,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Region) a
order by Total_Sales Desc
--------------------------
--7.Total Orders By Region

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Region,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Region) a
order by Total_orders Desc
-------------------------------
--8.Total Sales and Contribution By Region and State

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Region,
State,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Region,State) a
order by Region,Total_Sales Desc
---------------------------------
--9.Total Orders By Region and State

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Region,
State,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Region,State) a
order by Region,Total_orders Desc
------------------------------------
--10.Total Sales and Contribution By Category

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Category,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category) a
order by Total_Sales Desc
-------------------------
--11.Total Orders By Category

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Category,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category) a
order by Total_orders Desc
--------------------------
------------------------------------
--12.Total Sales and Contribution By Category and Sub Category

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category,Sub_Category) a
order by Category,Total_Sales Desc
------------------------------------
--13.Total Orders By Category and Sub-Category

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category,Sub_Category) a
order by Category,Total_orders Desc
-----------------------------------
--14.Top 5 Selling Sub-Categories by Sales

select TOP 5 *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category,Sub_Category) a
order by Total_Sales Desc
--------------------------------
--15.Bottom 5 Selling Sub-Categories by Sales
select TOP 5 *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category,Sub_Category) a
order by Total_Sales
--------------------
--16. Top 5 Selling Sub-Categories By Orders

select Top 5 *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category,Sub_Category) a
order by Total_orders Desc
--------------------------------
--17. Bottom 5 Selling Sub-Categories By Orders

select Top 5 *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Category,
Sub_Category,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category,Sub_Category) a
order by Total_orders
---------------------------
--18. Most Selling Products By Sales (Top 10)

select Top 10
Category,
Sub_Category,
Product_Name,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category,Sub_Category,Product_Name
order by Total_Sales Desc
-------------------------
--19 Least Selling Products By Sales (Bottom 10)

select Top 10
Category,
Sub_Category,
Product_Name,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Category,Sub_Category,Product_Name
order by Total_Sales
--------------------
--20 Most Selling Products By Orders (Top 10)

select Top 10
Category,
Sub_Category,
Product_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category,Sub_Category,Product_Name
order by Total_orders Desc
--------------------------
--21 Least Selling Products by Orders(Bottom 10)

select Top 10
Category,
Sub_Category,
Product_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Category,Sub_Category,Product_Name
order by Total_orders
---------------------

--Trend Analysis
--**************
--22. Yearly Contribution

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Year(Order_Date) as Years,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Year(Order_Date)) a
order by Years,Total_Sales Desc
-------------------------------
--23. YOY Performance Analysis

select *,
case 
	when Sales_Diff is null then 'No Previous Value'
	when Sales_Diff > 0 then 'Increasing'
	when Sales_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Sales_Status,
case
	when Sales_Diff is null then 0
	else ROUND((Cast(Total_Sales-py_sales as Float)/py_sales)*100,2) end as Yoy_perf

from
(
select *,
LAG(Total_sales) over (Order by Years) as PY_Sales,
Total_sales-LAG(Total_sales) over (Order by Years) as Sales_Diff
from
(
select
Year(Order_Date) as Years,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by YEAR(Order_Date) ) a ) b
------------------------------------
--24.Years wise orders
select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Year(Order_Date) as Years,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Year(Order_Date)) a
---------------------------------
--25.YoY Orders Performace
select *,
case 
	when order_Diff is null then 'No Previous Value'
	when order_Diff > 0 then 'Increasing'
	when order_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Order_Status,
case
	when py_orders is null then 0
	else ROUND((Cast(Total_orders-py_orders as Float)/py_orders)*100,2) end as Yoy_perf

from
(
select *,
LAG(Total_orders) over (Order by Years) as py_orders,
Total_orders-LAG(Total_orders) over (Order by Years) as order_Diff
from
(
select
Year(Order_Date) as Years,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by YEAR(Order_Date) ) a ) b
----------------------------------
--26. Quarterly Sales Contribution

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
CONCAT('Q',DATEPART(QUARTER,Order_Date)) as Quarter,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by CONCAT('Q',DATEPART(QUARTER,Order_Date))) a
order by Total_Sales Desc
-------------------------
--27. QoQ Sales and Performance Analysis

select *,
case 
	when Sales_Diff is null then 'No Previous Value'
	when Sales_Diff > 0 then 'Increasing'
	when Sales_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Sales_Status,
case
	when Sales_Diff is null then 0
	else ROUND((Cast(Total_Sales-py_sales as Float)/py_sales)*100,2) end as Yoy_perf

from
(
select *,
LAG(Total_sales) over (Order by Quarter) as PY_Sales,
Total_sales-LAG(Total_sales) over (Order by Quarter) as Sales_Diff
from
(
select
CONCAT('Q',DATEPART(QUARTER,Order_Date)) as Quarter,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by CONCAT('Q',DATEPART(QUARTER,Order_Date)) ) a ) b
--------------------------------------------------------------
--28.Quarter wise orders
select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
CONCAT('Q',DATEPART(QUARTER,Order_Date)) as Quarter,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by CONCAT('Q',DATEPART(QUARTER,Order_Date)) )a
order by Total_orders Desc
----------------------------
--29.QoQ Orders Performace

select *,
case 
	when order_Diff is null then 'No Previous Value'
	when order_Diff > 0 then 'Increasing'
	when order_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Order_Status,
case
	when pm_orders is null then 0
	else ROUND((Cast(Total_orders-pm_orders as Float)/pm_orders)*100,2) end as qoq_perf

from
(
select *,
LAG(Total_orders) over (Order by Quarter) as pm_orders,
Total_orders-LAG(Total_orders) over (Order by Quarter) as order_Diff
from
(
select
CONCAT('Q',DATEPART(QUARTER,Order_Date)) as Quarter,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by CONCAT('Q',DATEPART(QUARTER,Order_Date)) ) a ) b
----------------------------------------------------------
--30. Monthly Sales Contribution

select *,
SUM(Total_Sales) over() as Overall_sales,
CONCAT(ROUND(CAST(Total_Sales as FLOAT)/SUM(Total_Sales) over()*100,2),'%') as Contribution
from
(
select
Month(Order_Date) as Month,
LEFT(DATENAME(MONTH,Order_Date),3) as Month_Name,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by 
	Month(Order_Date),
	LEFT(DATENAME(MONTH,Order_Date),3)) a
order by Total_Sales Desc
-------------------------
--31. Monthly Performance

select *,
case 
	when Sales_Diff is null then 'No Previous Value'
	when Sales_Diff > 0 then 'Increasing'
	when Sales_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Sales_Status,
case
	when Sales_Diff is null then 0
	else ROUND((Cast(Total_Sales-pm_Sales as Float)/pm_Sales)*100,2) end as mom_perf

from
(
select *,
LAG(Total_sales) over (Order by Month) as pm_Sales,
Total_sales-LAG(Total_sales) over (Order by Month) as Sales_Diff
from
(
select
Month(Order_Date) as Month,
LEFT(DATENAME(MONTH,Order_Date),3) as Month_Name,
ROUND(SUM(sales),0) as Total_Sales
from sales
group by Month(Order_Date),LEFT(DATENAME(MONTH,Order_Date),3) ) a ) b
---------------------------------------------------------------------
--32. Month wise Order Volume Contribution

select *,
SUM(Total_orders) over() as Overall_orders,
CONCAT(ROUND(CAST(Total_orders as FLOAT)/SUM(Total_orders) over()*100,2),'%') as Contribution
from
(
select
Month(Order_Date) as Month,
LEFT(DATENAME(MONTH,Order_Date),3) as Month_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Month(Order_Date),LEFT(DATENAME(MONTH,Order_Date),3)) a
order by Total_orders Desc
--------------------------
--33. Monthly Orders Performance Analysis

select *,
case 
	when order_Diff is null then 'No Previous Value'
	when order_Diff > 0 then 'Increasing'
	when order_Diff < 0 then 'Decreasing'
	else 'No Difference'
	end Order_Status,
case
	when pm_orders is null then 0
	else ROUND((Cast(Total_orders-pm_orders as Float)/pm_orders)*100,2) end as mom_perf

from
(
select *,
LAG(Total_orders) over (Order by Month) as pm_orders,
Total_orders-LAG(Total_orders) over (Order by Month) as order_Diff
from
(
select
Month(Order_Date) as Month,
LEFT(DATENAME(MONTH,Order_Date),3) as Month_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by Month(Order_Date),LEFT(DATENAME(MONTH,Order_Date),3) ) a ) b
---------------------------------------------------------------------
--34.Top 10 Customers By Spending Behaviour

select Top 10
Customer_ID,
Customer_Name,
ROUND(SUM(Sales),0) as Total_Sales
from sales
group by 
	Customer_ID,
	Customer_Name
order by Total_Sales Desc
-------------------------
--35. Bottom 10 Customers By Spending Behaviour

select Top 10
Customer_ID,
Customer_Name,
ROUND(SUM(Sales),0) as Total_Sales
from sales
group by 
	Customer_ID,
	Customer_Name
order by Total_Sales
---------------------
--36. Top 10 Customers By Order Value

select Top 10
Customer_ID,
Customer_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by 
	Customer_ID,
	Customer_Name
order by Total_orders Desc
---------------------------
--37. Bottom 10 Customers By Orders
select Top 10
Customer_ID,
Customer_Name,
COUNT(DISTINCT Order_ID) as Total_orders
from sales
group by 
	Customer_ID,
	Customer_Name
order by Total_orders
----------------------
--38. Repeated Customers vs One-Time Buyers

select
Customer_type,
count(*) as Total_Customers
from
(
select
Customer_ID,
CASE
	when COUNT(DISTINCT Order_ID)>1 then 'Repeat Customer'
	else 'One-Time Buyer'
	end as Customer_type
from sales
group by
	Customer_ID) t
group by Customer_type
order by Total_Customers Desc

---------------
--39. Customer Segmentation
select
Customer_Segment,
COUNT(*) as Total_Customers
from
(
select *,
Case
	when Total_Orders >= 10 and Sales_Value > 10000 then 'VIP Customer'
	when Total_Orders < 10 and Sales_Value > 10000 then 'Premium Occasional'
	else 'Regular/New'
	end as Customer_Segment
from
(
select
Customer_ID,
count(DISTINCT Order_ID) as Total_Orders,
SUM(Sales) as Sales_Value
from sales
group by Customer_ID ) t) s
Group by Customer_Segment
order by Total_Customers Desc
----------------------------------
--=================================
--Creating View For Visualization

create view superstoresales_view as
with sales_data as (
    select
        Row_ID,
        Order_ID,
        CAST(Order_Date as date) as Order_Date,
        CAST(Ship_Date as date) as Ship_Date,
        Ship_Mode,
        Customer_ID,
        Customer_Name,
        Segment,
        City,
        State,
        Region,
        Product_ID,
        Category,
        Sub_Category,
        Product_Name,
        Sales
    from sales
),
customer_summary as (
    select
        Customer_ID,
        COUNT(DISTINCT Order_ID) as Total_Orders,
        SUM(Sales) as Sales_Value
    from sales_data
    group by Customer_ID
),
customer_segment as (
    select
        Customer_ID,
        Total_Orders,
        Sales_Value,
        case
            when Total_Orders >= 10 and Sales_Value > 10000 then 'VIP Customer'
            when Total_Orders < 10 and Sales_Value > 10000 then 'Premium Occasional'
            else 'Regular / New'
        end as Customer_Segment
    from customer_summary
)
select
    s.*,
    c.Customer_Segment
from sales_data s
left join customer_segment c
    on s.Customer_ID = c.Customer_ID


select * from superstoresales_view