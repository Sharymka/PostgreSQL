
create table products(
	id serial primary key,
	product_name varchar(70) unique  not null, 
	manufacturer_id int not null references manufacturers(id),
	category_id int not null references categories(id)
);

create table manufacturers(
	id serial primary key,
	manufacturer_name varchar(50) unique not null,
	manufacturer_country_id int not null references countries(id)
);

create table categories (
		id serial primary key,
		category_name varchar(50) unique not null
);


create table countries(
	id serial primary key,
	country_name varchar(40) unique not null
);


create table price_change(
	product_id int not null references products(id),
	date_price_change timestamp default now(),
	new_price int not null
);

create table store_branches(
	id serial primary key,
	branch_name varchar(20) unique not null,
	address_id int not null unique references addresses(id)
);

create table addresses(
	id serial primary key,
	town_id int not null references towns(id),
	street_id int not null references streets(id),
	building_number  varchar(10) not null,
	postal_code int 
);

create table towns(
	id serial primary key,
	town_name varchar(40) unique not null
);

create table streets(
	id serial primary key,
	street_name varchar(40) unique not null
);

create table customers(
	id serial primary key,
	first_name varchar(30) not null,
	last_name varchar(50),
	email varchar(120) unique not null,
	phone varchar(15) unique,
	password_hash varchar(255) unique not null
);

create table purchases(
	id serial primary key,
	customer_id int not null references customers(id),
	product_id int not null references products(id),
	product_count int not null,
	purchase_date timestamp
);

create table deliveries (
	purchase_id int not null unique references purchases(id),
	store_branch_id int not null references store_branches(id),
	delivery_date timestamp default now()
);



