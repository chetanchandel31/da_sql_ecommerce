select product_id,
round(avg(quantity) ,2) as AvgQuantity,
sum(price_per_unit * quantity) as TotalRevenue
from OrderDetails
group by product_id
order by AvgQuantity desc, TotalRevenue desc;