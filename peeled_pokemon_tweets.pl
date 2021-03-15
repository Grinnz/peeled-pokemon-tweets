#!/usr/bin/env perl

use 5.020;
use Mojolicious::Lite -signatures;
use Mojo::SQLite;
use Unicode::Normalize 'NFC';
use lib::relative 'lib';

push @{app->commands->namespaces}, 'PeeledPokemonTweets::Command';

plugin Config => {file => app->home->child('peeled_pokemon_tweets.conf')};

my $dbfile = app->home->child('peeled_pokemon_tweets.db');
my $migrations = app->home->child('peeled_pokemon_tweets.sql');
my $sqlite;
helper sqlite => sub ($c) {
  unless (defined $sqlite) {
    $sqlite = Mojo::SQLite->new->from_filename($dbfile);
    $sqlite->migrations->from_file($migrations)->migrate;
  }
  return $sqlite;
};

get '/api/tweet' => sub ($c) {
  my $name = $c->req->param('name') // return $c->reply->not_found;
  my $row = $c->sqlite->db->query(q{SELECT "pn"."dex_no", "pt"."tweet_url"
    FROM "pokemon_names" AS "pn"
    LEFT JOIN "pokemon_tweets" AS "pt" ON "pt"."dex_no"="pn"."dex_no"
    WHERE "pn"."name"=?}, NFC(fc $name))->hashes->first // return $c->reply->not_found;
  $c->render(json => $row);
};

app->start;
