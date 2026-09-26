with customer_to_num_of_orders as (
    select c.customer_id as customer_id, count(*) as num_of_orders
    from Customers c join Orders o on c.customer_id = o.customer_id
    group by c.customer_id
)
select num_of_orders,
count(*) as CustomerCount
from customer_to_num_of_orders
group by num_of_orders
order by num_of_orders asc;