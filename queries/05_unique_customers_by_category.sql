select p.category, count(distinct(o.customer_id)) as unique_customers
from orderdetails od join products p on od.product_id = p.product_id
join orders o on o.order_id = od.order_id
group by p.category
order by unique_customers desc;