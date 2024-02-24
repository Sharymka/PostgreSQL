

--������� �������������, ������� �� ����� �� ����� ��������� ����� � �������������� ��������.
--����� ������� ��� ������, ��������� � ������ ��������������. ��� ������� ����������� ����������.

--��������� ������� ��� �������� ���� ������������� ���� �� � �����  �������������� �������
create temporary table users_with_friends(
	user_id int
);

--��������� ������� ��� �������� ���� �������������, ������� ��������������� �������  ������
create temporary table users_without_friends(
	user_id int
);

insert into users_with_friends 
(select requested_from_user_id
from frienship f
where status_id = 3
	union
select requested_to_user_id
from frienship f
where status_id = 3);
 

insert into users_without_friends 
(select requested_from_user_id
from frienship f
where status_id != 3
	union
select requested_to_user_id
from frienship f
where status_id != 3);


delete from users_without_friends
where user_id in (select user_id from users_with_friends);

--����������
begin;

delete from frienship f 
where requested_from_user_id in (select user_id from users_with_friends)
or requested_to_user_id in (select user_id from users_with_friends);
	
delete from likes l
where user_id in (select user_id from users_with_friends);

update users set main_photo_id = null 
where id in (select user_id from users_with_friends); 

delete from media 
where owner_id in (select user_id from users_with_friends);

delete from messages  
where from_user_id in (select user_id from users_with_friends)
or to_user_id in (select user_id from users_with_friends);

delete from profiles  
where user_id in (select user_id from users_with_friends);

delete from users_communities  
where user_id in (select user_id from users_with_friends);

delete from users  
where user_id in (select user_id from users_with_friends);

commit;


--������� ������, ������� ��� ���� ������������� ������� ���������� ����������� ���������� � ����������� 
--(���������� ���������), � ����� ���� ������� ������������ �� ���� ��������� (
--����� �������� ��� ���������� � �����������). ������� �������� 
--������������� ����� �������� �����. ������ ������� ���������� ����� �������� � �������������� ������� �������.

with users_with_media_counts as (
select 
	distinct u.id,
	u.first_name,
	u.last_name,
	count(m.id = (select id from media_types mt where mt.name = 'photo')) over (partition by u.id) as photo_amount,
	count(m.id = (select id from media_types mt where mt.name = 'video')) over (partition by u.id) as video_amount
from users u 
	join media m on m.owner_id = u.id
order by u.id)
select 
	id,
	first_name,
	last_name,
	photo_amount,
	video_amount,
	dense_rank() over (order by photo_amount desc) as rank_by_photo,
	dense_rank() over (order by video_amount desc) as rank_by_video
from users_with_media_counts;

--* ��� ������ ������ (����������) ����� ������� ������ �����������, ����������� ����������� ������,
 --� ����� ������� �������������, ��� � ������� ������������, 
--������� �������� ����� ������� �� ������� ���������. 
--������ ������� ���������� ����� �������� � �������������� ������� �������.

select 
distinct cs.communities_id,
avg(m._size) over (partition by cs.communities_id) as avg_size,
max(m._size) over (partition by cs.communities_id) as max_size,
first_value (u.first_name) over(partition by cs.communities_id order by m._size desc) as first_name,
first_value (u.last_name) over(partition by cs.communities_id order by m._size desc) as last_name
from 
communities_subscription cs 
	join media m on cs.subscriber_id = m.owner_id
	join users u on u.id = subscriber_id 
	where m.media_type_id = (select id from media_types mt where name = 'video')
order by cs.communities_id;


