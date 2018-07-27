#!/usr/bin/env perl
package OpenGraphMeta;
use strict;
use warnings;
use autodie;

use MOP4Import::Base::CLI_JSON -as_base;

sub ogdict_to_meta {
  (my MY $self, my $ogDict) = @_;
  map {
    my $key = /^og:/ ? "property" : "name";
    $self->make_meta($key, $_, $ogDict->{$_});
  } sort keys %$ogDict;
}

sub make_meta {
  (my MY $self, my ($nameKey, $name, $value)) = @_;
  # XXX: escape!
  <<END;
<meta $nameKey="$name" content="$value">
END
}

sub add_twitter_card {
  (my MY $self, my $ogDict) = @_;
  $ogDict->{'twitter:card'} ||= 'summary';
  $ogDict;
}

sub read_og_tsv {
  (my MY $self, my $fn) = @_;
  +{
    map {
      my ($name, $value) = @$_;
      my $fullName = $name =~ /:/ ? $name : "og:$name";
      ($fullName, $value);
    } $self->read_tsv_as_tuples($fn)
  }
}

sub read_tsv_as_tuples {
  (my MY $self, my $fn) = @_;
  map {[split "\t"]} do {
    open my $fh, '<:utf8', $fn;
    chomp(my @lines = <$fh>);
    @lines;
  };
}

MY->run(\@ARGV) unless caller;

1;
