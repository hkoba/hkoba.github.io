package Foo;
use strict;
use warnings;
use Class::Accessor::Fields qw/foo bar baz/;

sub MY () {__PACKAGE__};

sub all {
  (my MY $self) = @_;
  ($self->{foo} // 0) + ($self->{bar} // 0) + ($self->{baz} // 0)
}

1;
