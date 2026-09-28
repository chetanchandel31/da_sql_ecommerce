create database if not exists e_commerce_company;

use e_commerce_company;

create table Customers (
    customer_id int default null,
    name text,
    location text
);
create table Products (
    product_id int default null,
    name text,
    category text,
    price int default null
);
create table Orders (
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

alter table Customers add primary key (customer_id);

alter table Products add primary key (product_id);

alter table Orders
    add primary key (order_id),
    add constraint fk_orders_customer foreign key (customer_id) references Customers(customer_id);

alter table OrderDetails
    add id int auto_increment primary key first,
    add constraint fk_od_order foreign key (order_id) references Orders(order_id),
    add constraint fk_od_product foreign key (product_id) references Products(product_id);