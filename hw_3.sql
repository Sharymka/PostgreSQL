////hw_2 task_3

select * from media;

alter table media add column metadata json;

insert into media (media_type_id, url, owner_id, metadata, _size) 
values (1, 'media.ru', 2, '{"id": 1, "url": "https://hostiq.ua/blog/what-is-url/", "size": 2}', 4);

insert into media (media_type_id, url, owner_id, metadata, _size) 
values (3, 'media1.ru', 2, '{"id": 2, "url": "https://test/", "size": 5}', 10);


insert into media (metadata) values;

alter table media drop metadata;


////hw_2 task_4

insert into users_communities (user_id, community_id) values (2 , 3);
insert into users_communities (user_id, community_id) values (2 , 2);
insert into users_communities (user_id, community_id) values (1 , 5);
insert into users_communities (user_id, community_id) values (4 , 2);
insert into users_communities (user_id, community_id) values (20 , 2);
insert into users_communities (user_id, community_id) values (6 , 4);
insert into users_communities (user_id, community_id) values (7 , 2);
insert into users_communities (user_id, community_id) values (12 , 3);
insert into users_communities (user_id, community_id) values (10 , 2);
insert into users_communities (user_id, community_id) values (27 , 5);
insert into users_communities (user_id, community_id) values (16 , 2);
insert into users_communities (user_id, community_id) values (15 , 4);
insert into users_communities (user_id, community_id) values (8 , 3);
insert into users_communities (user_id, community_id) values (9 , 5);
insert into users_communities (user_id, community_id) values (2 , 5);


insert into communities (name, creator_id) values ('Кулинария' , 4);
insert into communities (name, creator_id) values ('Спорт' , 2);
insert into communities (name, creator_id) values ('Музыка' , 22);
insert into communities (name, creator_id) values ('Танцы' , 10);
insert into communities (name, creator_id) values ('Автомобили' , 3);

alter table communities add column members int[];
select * from communities; 
select * from users_communities; 



update communities 
set members = ( select array_agg(user_id)
from users_communities
where community_id = 3)
where id = 3;




//hw_2 task_5

select * from users;

create type contacts as (email varchar(50), phone varchar(50));

alter table users add column user_contacts contacts;

update users set user_contacts.email = (users.email), user_contacts.phone = (users.phone); 

update users set user_contacts.email = 'test@somemail.ru' 
where id = 21;
