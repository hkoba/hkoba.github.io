#!/usr/bin/env perl
package OpenGraphMeta;
use strict;
use warnings;

use MOP4Import::Base::CLI_JSON -as_base;

use File::Slurp;

sub read_tsv {
  (my MY $self, my $fn) = @_;
  map {split "\t"} read_file($fn, binmode => ':utf8');
}

MY->run(\@ARGV) unless caller;

1;
