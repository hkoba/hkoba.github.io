#!/usr/bin/env perl
package MyScript2;
use strict;
use warnings;

use Data::Dumper;

#----------------------------------------

use File::stat;

sub list_dirs_with_mtime {
  my ($self, @dirs) = @_;
  map {+{dir => $_, mtime => stat($_)->mtime}} @dirs;
}

#----------------------------------------


sub new {
  my $pack = shift;
  bless {@_}, $pack;
}

sub parse_long_opts {
  my ($list, $result) = @_;
  $result //= [];
  while (@$list and my ($n, $v) = $list->[0]
         =~ m{^--$ | ^(?:--? ([\w:\-\.]+) (?: =(.*))?)$}xs) {
    shift @$list;
    last unless defined $n;
    push @$result, $n, $v // 1;
  }
  wantarray ? @$result : $result;
}

sub cmd_help {
  my ($self, @msg) = @_;
  die @msg, <<END;
Usage: $0 [--option=value]... COMMAND ARGS...
END
}

unless (caller) {
  my $self = __PACKAGE__->new(parse_long_opts(\@ARGV));

  my $cmd = shift || 'help';

  if (my $sub = $self->can("cmd_$cmd")) {
    $sub->($self, @ARGV);
  } elsif ($sub = $self->can($cmd)) {
    print Dumper($sub->($self, @ARGV));
  } else {
    $self->cmd_help("No such command: $cmd");
  }
}

1;
