#!/usr/bin/env perl
use strict;
use warnings;
use Class::Accessor::Fields qw/foo bar baz/;

sub MY () {__PACKAGE__};

sub foo {
  my MY $foo = shift;
  $foo->{fo} + $foo->{bar}
}

1;
