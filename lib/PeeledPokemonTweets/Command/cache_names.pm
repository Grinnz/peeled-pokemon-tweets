package PeeledPokemonTweets::Command::cache_names;

use Mojo::Base 'Mojolicious::Command', -signatures;
use Encode::Simple 'encode_utf8';
use Future::Utils 'repeat';
use List::Util qw(first uniqstr);
use Mojo::Promise;
use Mojo::UserAgent;
use Mojo::URL;
use Unicode::Normalize 'NFC';

use constant POKEAPI_BASE_URL => 'https://pokeapi.co/api/v2/';

has description => 'Cache pokemon names by dex number';
has usage => sub ($self) { "Usage: $0 cache-names\n" };

has ua => sub ($self) { Mojo::UserAgent->new };

sub run ($self, @args) {
  my $ua = $self->ua;
  my $url = Mojo::URL->new(POKEAPI_BASE_URL);
  push @{$url->path}, 'pokemon-species';
  $url->query->append(limit => 100);
  my $f = repeat {
    my $next_url = defined $_[0] ? $_[0]->get : $url;
    $ua->get_p($next_url)->then(sub ($tx) {
      my $data = $tx->res->json;
      my $p = Mojo::Promise->map({concurrency => 5}, sub {
        $ua->get_p($_)->then(sub ($tx) {
          $self->cache_pokemon_names($tx->res->json);
        });
      }, map { $_->{url} } @{$data->{results}});
      return $p->then(sub { $data->{next} });
    })->with_roles('Mojo::Promise::Role::Futurify')->futurify;
  } while => sub ($f) { defined $f->get };
  $f->get;
};

sub cache_pokemon_names ($self, $data) {
  my $dex_entry = first { $_->{pokedex}{name} eq 'national' } @{$data->{pokedex_numbers}};
  my $dex_no = defined $dex_entry ? $dex_entry->{entry_number} : $data->{id};
  my @names = uniqstr map { NFC fc $_->{name} } @{$data->{names}};
  return 0 unless @names;
  print encode_utf8 "Caching names for Dex No $dex_no: @names\n";
  my $insert_str = join ',', ('(?,?)')x@names;
  $self->app->sqlite->db->query('INSERT OR IGNORE INTO "pokemon_names" ("dex_no","name")
    VALUES ' . $insert_str, map { ($dex_no, $_) } @names)->rows;
};

1;
