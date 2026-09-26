select product_id,
count(*) as SalesFrequency
from OrderDetails
group by product_id
order by SalesFrequency desc
limit 5;