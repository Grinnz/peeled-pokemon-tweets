package PeeledPokemonTweets::Command::cache_tweets;

use Mojo::Base 'Mojolicious::Command', -signatures;
use Mojo::WebService::Twitter;

has description => 'Cache peeled pokemon tweets by dex number';
has usage => sub ($self) { "Usage: $0 cache-tweets\n" };

has twitter => sub ($self) {
  my ($api_key, $api_secret) = @{$self->app->config}{'twitter_api_key','twitter_api_secret'};
  die "twitter_api_key and twitter_api_secret required to retrieve peeled pokemon tweets\n"
    unless defined $api_key and defined $api_secret;
  return Mojo::WebService::Twitter->new(api_key => $api_key, api_secret => $api_secret);
};

sub run ($self, @args) {
  
};

1;
