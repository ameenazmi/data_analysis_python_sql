select * from df_orders

--top 10 highest revenue products
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales DESC

--top 5 highest products in each region
with cte as (
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from(
select *
, row_number() over (
partition by region 
order by sales DESC ) as rn
from cte) A
where rn <= 5

--sales comparison between 2022 and 2023 by months
with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
select order_month,
	sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
	sum(case when order_year = 2023 then sales else 0 end) as sales_2023,
	sum(case when order_year = 2023 then sales else 0 end) - sum(case when order_year = 2022 then sales else 0 end) as sales_difference
from cte
group by order_month
order by order_month

--Highest sales category by months
with cte as (
select category, format(order_date, 'yyyyMM') as order_month, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
--order by order_date asc
)
select *
from(
select *, ROW_NUMBER() over (partition by category order by sales desc) as rn
from cte) a
where rn <=3

-- top 5 highest growth profit in 2023 compare to 2022 by sub category
with cte as(
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
),
cte2 as(
select sub_category, 
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 5 *, 
(sales_2023 - sales_2022)/sales_2022 * 100 as growth
from cte2
order by growth desc