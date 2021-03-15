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
