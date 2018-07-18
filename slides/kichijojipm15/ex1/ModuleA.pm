#!/usr/bin/env perl
package ModuleA;
use strict;
use warnings;
use List::Util qw/pairs sum/;

sub new {
  my $class = shift;
  bless {}, $class;
}

sub foo {
  'なにか'
}

sub as_string {
  my ($self) = @_;
  join(" ", map {"$_:$self->{$_}"} sort keys %$self)
}

sub count_pairs {
  my ($self, @pairList) = @_;
  foreach my $pair (@pairList) {
    my ($k, $v) = @$pair;
    $self->{$k} += $v;
  }
  $self;
}

sub total {
  my ($self) = @_;
  sum(values %$self);
}

sub main {
  my ($class, @args) = @_;

  my $obj = $class->new;

  $obj->count_pairs(pairs @args);

  print $obj->as_string, "\n";

}

unless (caller) {

  __PACKAGE__->main(@ARGV);

}

1;
