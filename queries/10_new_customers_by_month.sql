with customer_to_first_purchase_month as (
	select customer_id,
	date_format(min(order_date), "%Y-%m") as FirstPurchaseMonth 
	from orders
	group by customer_id
)
select FirstPurchaseMonth ,
count(*) as TotalNewCustomers
from customer_to_first_purchase_month
group by FirstPurchaseMonth 
order by FirstPurchaseMonth  asc;