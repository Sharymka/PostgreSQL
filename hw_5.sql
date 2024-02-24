create table likes_id_50_100 (
	check(id > 50 and id <=100)
	)inherits(likes);

create table likes_id_100_200 (
	check(id > 100 and id <=200)
	)inherits(likes);

create rule like_insert_to_likes_id_50_100 as on insert to likes
where (id > 50 and id <=100)
do instead insert into likes_id_50_100 values(new.*);

create rule like_insert_to_likes_id_100_200 as on insert to likes
where (id > 100 and id <=200)
do instead insert into likes_id_100_200 values(new.*);

create rule like_delete_from_likes_id_50_100 as on delete from likes
where (id > 50 and id <=100)
do delete into likes_id_50_100 values(new.*);

create rule like_insert_to_likes_id_100_200 as on insert to likes
where (id > 100 and id <=200)
do instead insert into likes_id_100_200 values(new.*);