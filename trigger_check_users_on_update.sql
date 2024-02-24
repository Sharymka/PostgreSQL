create or replace function update_users_main_photo_id()
returns trigger 
language plpgsql
as
$$
declare real_user_id int;
begin
	 real_user_id = 
	(select owner_id 
	from media 
	where id  = new.main_photo_id);
	if new.main_photo_id is not null and real_user_id != new.id then
	raise exception 'User with ID: % has no photo with ID: %', new.id, new.main_photo_id;
	end if;
	return new;
end;
$$;

create trigger check_users_on_update before update on users
for each row 
execute function update_users_main_photo_id();


update users set main_photo_id = 3 where id = 12;

select * from media where owner_id = 12;