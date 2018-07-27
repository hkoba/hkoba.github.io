#!/usr/bin/env perl
package OpenGraphMeta;
use strict;
use warnings;

use MOP4Import::Base::CLI_JSON -as_base;

use File::Slurp;

sub read_og_tsv {
  (my MY $self, my $fn) = @_;
  map {
    my ($name, $value) = @$_;
    my $fullName = $name =~ /:/ ? $name : "og:$name";
    ($fullName, $value);
  } $self->read_tsv_as_tuples($fn)
}

sub read_tsv_as_tuples {
  (my MY $self, my $fn) = @_;
  map {chomp; [split "\t"]} read_file($fn, binmode => ':utf8');
}

MY->run(\@ARGV) unless caller;

1;
