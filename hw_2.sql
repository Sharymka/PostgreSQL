
--таблица пользователей
create table users(
	id serial primary key,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(120) unique not null,
	phone varchar(15) unique,
	password_hash varchar(255),
	main_photo_id int,
	created_at timestamp default current_timestamp
);


--таблица сообщений
create table messages(
	id serial primary key,
	from_user_id int not null references users(id),
	to_user_id int not null references users(id),
	body text,
	is_important boolean,
	is_delivered boolean,
	is_read boolean,
	created_at timestamp default now()
);


--таблица профилей
create table profiles(
	user_id int not null unique references users(id),
	birthday date,
	hometown varchar(50),
	gender char(1)
);

--таблийа статусов дружбы
create table friendship_statuses(
	id serial primary key,
	name varchar(50) unique
);

--таблица дружбы
create table frienship(
	id serial primary key,
	requested_from_user_id int not null references users(id),
	requested_to_user_id int not null references users(id),
	status_id int not null references friendship_statuses(id),
	requested_at timestamp,
	comnfirmed_at timestamp
);

-- таблица сообществ
create table communities(
	id serial primary key,
	name varchar(120) unique,
	creator_id int not null references users(id),
	created_at timestamp default now()
);

--таблица св€зей сообщества и пользователей
create table users_communities(
	user_id int not null references users(id),
	community_id int not null references users(id),
	created_at timestamp default now(),
	primary key (user_id, community_id)
);


--таблица типов медиа
create table media_types(
	id serial primary key,
	name varchar(50) not null unique
); 

--“аблица медиа
create table media(
	id serial primary key,
	media_type_id int not null references media_types(id),
	url varchar(120) not null,
	owner_id int not null references users(id),
	description varchar(250),
	upload_at timestamp not null default now(),
	_size int not null,
);

--таблица лайков
create table likes(
	id serial primary key,
	user_id int not null references users(id),
	media_id int not null references media(id),
	created_at timestamp default now()
);


--таблица подписка на сообщества
create table communities_subscription(
	subscriber_id int not null references users(id),
	communities_id int references communities(id),
	primary key(subscriber_id, communities_id)
);

--таблица подписка на пользовател€ 
create table users_subscription(
	subscriber_id int not null references users(id),
	user_id int references users(id),
	primary key(subscriber_id, user_id)
);

-- таблица новости 
create table news(
	owner_id int references users(id),
	body text,
	media_id int references media(id),
	created_at timestamp default now(),
	_size int not null
);

alter table news add column id serial primary key; 

--таблица св€зей пользователи и новости
create table users_news(
	user_id int references users(id),
	news_id int references news(id),
	primary key(user_id, news_id)
);

--таблица описание музыки
create table music_description(
	id serial primary key,
	media_id int references media(id),
	author varchar(50) not null,
	title varchar(20) not null,
	album_name varchar(20) not null,
	_size int not null
);

--таблица плейлист
create playlist(
	user_id int references users(id),
	music_description_id references music_description(id),
	primary key(user_id, music_description_id)
	
);

ALTER TABLE users add constraint main_photo_id foreign key (main_photo_id) REFERENCES media (id);
ALTER TABLE users_communities DROP CONSTRAINT users_communities_community_id_fkey, ADD FOREIGN KEY (community_id) REFERENCES communities(id);
