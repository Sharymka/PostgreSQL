
--task №2
create or replace function older_18 (id int)
returns boolean
as 
$$
declare user_age int;
begin 
	select extract(year from age(now(), birthday)) into
	user_age
	from profiles 
	where user_id = id;
	return user_age > 18;
end;
$$ language plpgsql;

select * from older_18(3);

--task №4

create or replace function find_user(user_id int) 
returns int
language plpgsql
as
$$
declare from_user_id_max_messages int;
begin
	from_user_id_max_messages := 
	(select _table.from_user_id
	from 
		(select from_user_id,
		count(from_user_id) as message_count
		from messages m 
		where to_user_id = user_id
		group by (from_user_id)
		order by message_count desc 
		limit 1) 
		as _table); 
return from_user_id_max_messages;	
end;
$$


select * from find_user(10);

--task №1

--Создать два представления для таблицы media. Одно представление 
--должно показывать фотографии, а другое остальные типы и имена владельцев файлов.


create or replace view select_photos as
select m.url
from media m
	join media_types mt on m.media_type_id = mt.id
where mt.name = 'photo';


create or replace view other_media as
select m.url, u.first_name, u.last_name
from media m 	
	join media_types mt on m.media_type_id = mt.id 
	join users u on m.owner_id = u.id 
where mt."name" !='photo';	


select * from select_photos;

select * from other_media;

--task №3
 --Создать триггер на обновление для таблицы пользователей, 
 --который не разрешает менять дату рождения пользователя,
 --если после изменения ему будет меньше 18 лет

create function update_profiles_birthday_trigger()
returns trigger
language plpgsql
as
$$
declare  years int; 
begin	
	years = (select extract ('years' from (select age(new.birthday))));
    if years < 18 then
    raise exception 'User with ID : % can not change birthday to : %, it is younger than 18 years', new.user_id, new.birthday;
    end if;
    return new;
end;
$$;

drop  function update_profiles_birthday_trigger cascade ;

create trigger check_birthday_on_update before update on profiles
	for each row 
execute function update_profiles_birthday_trigger(); 


update profiles set birthday = '2020-05-06' where user_id = 3;




