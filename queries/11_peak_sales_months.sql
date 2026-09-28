select date_format(order_date, "%Y-%m") as Month,
sum(total_amount) as TotalSales
from orders
group by date_format(order_date, "%Y-%m")
order by TotalSales desc limit 3;