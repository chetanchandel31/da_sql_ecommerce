select * from products;

select od.product_id, p.name,
count(distinct(c.customer_id)) as UniqueCustomerCount
from OrderDetails as od join products p on od.product_id = p.product_id
join orders o on o.order_id = od.order_id
join customers c on o.customer_id = c.customer_id
group by od.product_id, p.name
having count(distinct(c.customer_id)) < (select count(distinct(customer_id)) from customers) * 40/100;