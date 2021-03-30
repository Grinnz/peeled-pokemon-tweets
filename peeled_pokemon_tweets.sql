-- 1 up
create table "pokemon_tweets" (
  dex_no integer not null primary key,
  tweet_url text not null,
  image_url text not null
);
create table "pokemon_names" (
  name text not null primary key,
  dex_no integer not null
);
create index "pokemon_names_dex_no" ON "pokemon_names" ("dex_no");

--1 down
drop table "pokemon_tweets";
drop table "pokemon_names";

--2 up
create table "pokemon_images" (
  dex_no integer not null,
  image_id integer not null default 0,
  image_url text not null
);
create unique index "pokemon_images_dex_no_image_id" on "pokemon_images" ("dex_no","image_id");

insert into "pokemon_images" ("dex_no","image_id","image_url") select "dex_no", 0, "image_url" from "pokemon_tweets";

create table "pokemon_tweets_NEW" (
  dex_no integer not null primary key,
  tweet_url text not null
);
insert into "pokemon_tweets_NEW" ("dex_no","tweet_url") select "dex_no", "tweet_url" from "pokemon_tweets";
drop table "pokemon_tweets";
alter table "pokemon_tweets_NEW" rename to "pokemon_tweets";

--2 down
drop table "pokemon_images";
