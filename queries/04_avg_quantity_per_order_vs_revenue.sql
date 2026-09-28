select od.product_id, p.name,
round(avg(od.quantity) ,2) as AvgQuantity,
sum(od.price_per_unit * quantity) as TotalRevenue
from OrderDetails od left join Products p on od.product_id = p.product_id
group by product_id
order by AvgQuantity desc, TotalRevenue desc;