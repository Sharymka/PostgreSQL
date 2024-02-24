
-- first option using nested query
select 
	id, 
	url, 
	_size, 
	owner_id,
	(select main_photo_id from users where media.owner_id = users.id) as main_photo_id ,
	(select first_name from users where media.owner_id = users.id) as first_name ,
	(select last_name from users where media.owner_id = users.id) as last_name ,
 	(select url from media m where m.id = (select main_photo_id from users where media.owner_id = users.id)) as url_main_photo
from media
where media_type_id = (select id from media_types where name = 'video')
order by main_photo_id desc
limit 10;

select * from media where id = 33 order by url desc;
select main_photo_id  from users order by main_photo_id ;
select *  from users where main_photo_id = 49 order by main_photo_id ;

select main_photo_id from users where id = media.owner_id;

select url from media where id = (select main_photo_id from users where );

select url, owner_id from media where id = (select main_photo_id from users where id = media.owner_id);


-- second option using join

select m.id, url, _size, first_name, last_name,
(select url as user_main_photo_url from media 
where id = u.main_photo_id)
from media m 
	join users u on u.id = m.owner_id 	
where media_type_id = 
	(select id from media_types where name = 'video')
order by _size desc
limit 10;	

--third option using tamperary table

create temporary table media_data (
	media_id bigint,
	url varchar(50),
	_size bigint,
	first_name varchar(50),
	last_name varchar(50),
	url_main_photo varchar(50)
);


insert into media_data 
select m.id, url, _size, first_name, last_name,
(select url as user_main_photo_url from media m 
where m.id = u.main_photo_id)
from media m 
	join users u on u.id = m.owner_id 	
where media_type_id = 
	(select id from media_types where name = 'video')
order by _size desc
limit 10;

select * from media_data;

delete from media_data;


--fourth option using table expression

WITH media_data AS (
SELECT id, _size, url, owner_id, 
(select url as main_photo_url from media m where m.id = 
	(select main_photo_id from users where media.owner_id = users.id)) 
FROM media
where media_type_id = 
	(select id from media_types where name = 'video')
order by _size desc
limit 10
)
SELECT
media_data.id AS media_id,
media_data._size as _size,
media_data.url,
media_data.main_photo_url,
concat(first_name, ' ', last_name) as _user 
from users 
	join media_data on media_data.owner_id = users.id; 

	
