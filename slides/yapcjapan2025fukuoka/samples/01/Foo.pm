#!/usr/bin/perl
use v5.40; use feature 'class'; no warnings qw(experimental::class);

class Foo;

sub bar {"baz"}

unless (caller) {
  print Foo->bar(@ARGV), "\n";
}
