
--вложенные запросы
select 
	concat((select  first_name from customers where id =
		(select customer_id from purchases  where id = d.purchase_id)), ' ', 
	(select  last_name from customers where id =
		(select customer_id from purchases  where id = d.purchase_id))) as customer_name,
	(select product_name from products where id = 
		(select product_id from purchases where id = d.purchase_id)),
	(select branch_name from store_branches where id = d.store_branch_id),
	delivery_date
from deliveries d
where delivery_date > now() - interval '6 month'
order by delivery_date desc;


select 
	(select product_name from products  where id = p.product_id),
	concat ((select first_name from customers where id = p.customer_id),
		(select last_name from customers where id = p.customer_id)) as customer_name,
	(select category_name from categories c where id = 
		(select category_id from products where id = p.product_id)),
	(select manufacturer_name from manufacturers  where id = 
		(select manufacturer_id from products where id = p.product_id)),
	product_count
from purchases p 
where product_count > 3
order by product_count;


-- запросы с join
with customer_purchases as (
select
	cu.id as customer_id,
	concat (cu.first_name, cu.last_name) as customer_name,
	m.manufacturer_name,
	pr.product_name,
	pu.product_count,
	count(pu.id) over (partition by cu.id) as purchase_count
from purchases pu
	join products pr on pu.product_id = pr.id
	join manufacturers m on pr.manufacturer_id = m.id
	join customers cu on pu.customer_id = cu.id
	join categories ca on pr.category_id = ca.id
where product_count > 3
order by cu.id)
select customer_purchases.*,
dense_rank() over (order by purchase_count desc)
from customer_purchases;


with category_products as (
select distinct 
	ca.category_name,
	SUM(pu.product_count) over (partition by ca.category_name) as product_amount
from purchases pu
	join products pr on pu.product_id = pr.id
	join manufacturers m on pr.manufacturer_id = m.id
	join categories ca on pr.category_id = ca.id
where pu.purchase_date > now() - interval '3 month'
order by product_amount)  
select category_products.*,
dense_rank() over (order by product_amount desc)
from category_products;

--представления
create or replace view select_addresses as
select 
	pr.product_name,
	sb.branch_name,
	t.town_name,
	s.street_name,
	a.building_number,
	a.postal_code,
	d.delivery_date
from deliveries d
	join purchases pu on pu.id = d.purchase_id
	join products pr on pr.id = pu.product_id
	join store_branches sb on d.store_branch_id = sb.id
	join addresses a on sb.address_id = a.id
	join towns t on a.town_id = t.id
	join streets s on a.street_id = s.id
where text(d.delivery_date)  like '2023-02%'
order by d.delivery_date;

select * from select_addresses;


create or replace view  product_change_price as
select 
pr.product_name,
ca.category_name,
pc.date_price_change,
pc.new_price
from price_change pc
	right join products pr on pc.product_id = pr.id
	join categories ca on pr.category_id = ca.id
--where pr.product_name = 'tempus'
where pc.date_price_change > now() - interval '1 year'
order by pr.product_name, pc.date_price_change;


-- функция
create or replace function avg_product_count_of_category_for_last_year (category_type varchar) 
returns int
language plpgsql
as 
$$
declare avg_product_count int; 
begin 
	avg_product_count := 
	(select distinct  
	sum(pu.product_count) over (partition by ca.category_name)
	from deliveries d 
	join purchases pu on d.purchase_id = pu.id
	join products pr on pu.product_id = pr.id
	join categories ca on pr.category_id = ca.id
	where ca.category_name = category_type
	and d.delivery_date > now() - interval '1 year');
return avg_product_count;
end;
$$;

select * from avg_product_count_of_category_for_last_year('Tableware');
drop function avg_product_count_of_category_for_last_year;

--триггур

create or replace function insert_delivery_trigger()
returns trigger 
language plpgsql
as
$$
declare date_of_purchase timestamp; date_of_delivery timestamp;
begin 
	date_of_delivery = (select new.delivery_date);
	date_of_purchase = (select purchase_date from purchases where id = new.purchase_id);
	if date_of_delivery > date_of_purchase + interval '3 days' then 
	raise exception 'Delivery time should not be more than 3 days';
	end if;
return new;
end;
$$;

create trigger check_delivery_date_on_update before insert on deliveries 
for each row
execute function insert_delivery_trigger();

insert into purchases (customer_id, product_id, product_count, purchase_date) values (56, 34, 5, '2023-08-11');
insert into deliveries (purchase_id, store_branch_id, delivery_date) values (1001, 4, '2023-08-16');
insert into deliveries (purchase_id, store_branch_id, delivery_date) values (1001, 4, '2023-08-12');


--оптимизация 

 explain analyse with customer_purchases as (
select
	cu.id as customer_id,
	concat (cu.first_name, cu.last_name) as customer_name,
	m.manufacturer_name,
	pr.product_name,
	pu.product_count,
	count(pu.id) over (partition by cu.id) as purchase_count
from purchases pu
	join products pr on pu.product_id = pr.id
	join manufacturers m on pr.manufacturer_id = m.id
	join customers cu on pu.customer_id = cu.id
	join categories ca on pr.category_id = ca.id
where product_count > 3
order by cu.id)
select customer_purchases.*,
dense_rank() over (order by purchase_count desc)
from customer_purchases;


create index purchases_product_id_fk on purchases(product_id);
create index purchases_customer_id_fk on purchases(customer_id);
create index products_category_id_fk on products(category_id);


SET enable_seqscan TO OFF;


drop index purchases_product_id_fk;
drop index purchases_customer_id_fk;
drop index products_category_id_fk;