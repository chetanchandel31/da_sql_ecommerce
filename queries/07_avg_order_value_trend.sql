with month_to_avg_order as (
	select date_format(order_date, "%Y-%m") as Month,
	round(avg(total_amount), 2) as AvgOrderValue,
	lag(round(avg(total_amount), 2)) over(order by date_format(order_date, "%Y-%m") asc) as prev_month_avg_order_value 
	from orders
	group by date_format(order_date, "%Y-%m") 
) 
select Month, AvgOrderValue,
AvgOrderValue - prev_month_avg_order_value as ChangeInValue
from month_to_avg_order
order by ChangeInValue desc;
