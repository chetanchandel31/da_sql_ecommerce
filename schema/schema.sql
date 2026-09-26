create database if not exists e_commerce_company;

use e_commerce_company;

create table customers (
    customer_id int default null,
    name text,
    location text
);
create table products (
    product_id int default null,
    name text,
    category text,
    price int default null
);
create table orders (
    order_id int default null,
    order_date text,
    customer_id int default null,
    total_amount int default null
);
create table OrderDetails (
    order_id int default null,
    product_id int default null,
    quantity int default null,
    price_per_unit int default null
);

alter table customers add primary key (customer_id);

alter table products add primary key (product_id);

alter table orders
    add primary key (order_id),
    add constraint fk_orders_customer foreign key (customer_id) references customers(customer_id);

alter table OrderDetails
    add id int auto_increment primary key first,
    add constraint fk_od_order foreign key (order_id) references orders(order_id),
    add constraint fk_od_product foreign key (product_id) references products(product_id);