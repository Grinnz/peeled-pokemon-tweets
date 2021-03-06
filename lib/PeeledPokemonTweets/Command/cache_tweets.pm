package PeeledPokemonTweets::Command::cache_tweets;

use 5.020;
use Mojo::Base 'Mojolicious::Command', -signatures;
use Future::Utils 'repeat';
use Math::BigInt;
use Mojo::WebService::Twitter;

use constant TWEET_BASE_URL => 'https://twitter.com/i/status';

has description => 'Cache peeled pokemon tweets by dex number';
has usage => sub ($self) { "Usage: $0 cache-tweets [<screen-name>]\n" };

sub run ($self, @args) {
  my $screen_name = shift @args // 'peeled_pokemon';
  my ($api_key, $api_secret) = @{$self->app->config}{'twitter_api_key','twitter_api_secret'};
  die "twitter_api_key and twitter_api_secret required to retrieve peeled pokemon tweets\n"
    unless defined $api_key and defined $api_secret;
  my $twitter = Mojo::WebService::Twitter->new(api_key => $api_key, api_secret => $api_secret);
  $twitter->authentication($twitter->request_oauth2);
  
  my $f = repeat {
    my $max_id = defined $_[0] ? $_[0]->get : undef;
    my %params = (count => 200, exclude_replies => 1, exclude_rts => 1);
    $params{max_id} = $max_id if defined $max_id;
    $twitter->get_user_timeline_p(screen_name => $screen_name, %params)->then(sub ($timeline) {
      return undef unless @$timeline;
      $self->cache_tweet($_) for @$timeline;
      my $last_id = $timeline->last->id;
      return Math::BigInt->new($timeline->last->id)->bsub(1)->bstr;
    })->with_roles('Mojo::Promise::Role::Futurify')->futurify;
  } while => sub ($f) { defined $f->get };
  $f->get;
}

sub cache_tweet ($self, $tweet) {
  my ($text, $media) = ($tweet->text, $tweet->media);
  my ($dex_no) = $text =~ m/([0-9]{3,})[ ]*\./;
  my @image_urls = map { $_->media_url } grep { $_->type eq 'photo' } @$media;
  return 0 unless defined $dex_no and @image_urls;
  my $tweet_url = Mojo::URL->new(TWEET_BASE_URL);
  push @{$tweet_url->path}, $tweet->id;
  print "Caching tweet and image URLs for Dex No $dex_no: $tweet_url @image_urls\n";
  my $tweet_inserted = $self->app->sqlite->db->query('INSERT OR IGNORE INTO "pokemon_tweets"
    ("dex_no","tweet_url") VALUES (?,?)', $dex_no, $tweet_url)->rows;
  my $values_str = join ',', ('(?,?,?)')x@image_urls;
  my $images_inserted = $self->app->sqlite->db->query('INSERT OR IGNORE INTO "pokemon_images"
    ("dex_no","image_id","image_url") VALUES ' . $values_str,
    map { ($dex_no, $_, $image_urls[$_]) } 0..$#image_urls)->rows;
}

1;
