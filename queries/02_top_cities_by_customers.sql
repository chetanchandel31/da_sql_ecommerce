select location,
count(*) as number_of_customers
from Customers
group by location
order by number_of_customers desc
limit 3;