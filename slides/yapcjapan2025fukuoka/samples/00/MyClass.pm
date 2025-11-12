#!/usr/bin/env perl
package MyClass;
use MouseX::OO_Modulino -as_base;

has foo => (is => 'rw', isa => 'Str', documentation => "is string");

has bar => (is => 'rw', isa => 'ArrayRef[Int]');

sub funcA {
  my ($self, $param) = @_;
  [$self->{foo}, $param, $self->{bar}]
}

sub funcB {
  my ($self, $param) = @_;
  +{foo => $self->{foo}, bar => $self->{bar}, baz => $param}
}

__PACKAGE__->cli_run(\@ARGV) unless caller;
1;
