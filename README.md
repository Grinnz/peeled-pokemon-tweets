# Peeled Pokémon Tweets

Stores and returns [peeled Pokémon](https://twitter.com/peeled_pokemon) by name.

## Setup

Perl 5.20+ required.

Create peeled_pokemon_tweets.conf.

```
{
  hypnotoad => {
    listen => ['http://*:8080'], # 8080 is default for hypnotoad
  },
  logfile => '/var/log/peeled.log',
  twitter_api_key => 'XXXXXXXXXX',
  twitter_api_secret => 'XXXXXXXXXXXXXXX',
}
```

Install the Perl dependencies.

```
$ cpanm --installdeps .
```

Start the application.

```
$ ./peeled_pokemon_tweets.pl daemon --listen='http://*:3000'
```

Or with hypnotoad (production web server):

```
$ hypnotoad peeled_pokemon_tweets.pl
```

## Cache Names

```
$ ./peeled_pokemon_tweets.pl cache-names
```

Caches mappings of Pokémon names to national dex number in various languages using https://pokeapi.co/.

## Cache Tweets

```
$ ./peeled_pokemon_tweets.pl cache-tweets
```

Caches mappings of national dex number to tweet and image URLs from the feed of https://twitter.com/peeled_pokemon.

## API

```
GET /api/peeled?name=dustox
```

```
{
  "dex_no":269,
  "image_url":"https:\/\/pbs.twimg.com\/media\/Em_kPTmWEAg7BgF.png",
  "tweet_url":"https:\/\/twitter.com\/i\/status\/1328531387691970560"
}
```

## Copyright and License

This software is Copyright (c) 2021 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)
