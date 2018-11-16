#!/usr/bin/env perl
package MyScript9;
use MOP4Import::Base::CLI_JSON -as_base
  , [fields => qw/dbi to/];

our $VERSION = 0.001;

use File::stat;

sub list_dirs_with_mtime {
  my ($self, @dirs) = @_;
  map {+{dir => $_, mtime => stat($_)->mtime}} @dirs;
}

__PACKAGE__->run(\@ARGV) unless caller;

1;
