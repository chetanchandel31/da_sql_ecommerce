select Month, TotalSales,
round((TotalSales - prev_month_sales) * 100 / prev_month_sales, 2) as PercentChange
from (
	select date_format(order_date, "%Y-%m") as Month,
	sum(total_amount) as TotalSales,
	lag(sum(total_amount)) over (order by date_format(order_date, "%Y-%m") asc) as prev_month_sales
	from orders
	group by date_format(order_date, "%Y-%m")
	order by Month asc
) as sub;