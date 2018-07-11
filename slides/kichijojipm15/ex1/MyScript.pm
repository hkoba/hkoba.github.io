#!/usr/bin/env perl
package MyScript;
use strict;
use warnings;

sub new {
  my $pack = shift;
  bless {@_}, $pack;
}

sub emit_tsv { shift; print join("\t", map {($_ // '') =~ s/[\t\n]/ /gr} @_), "\n"; }

sub main {
  my ($self, @args) = @_;
  my @header = sort keys %$self;
  $self->emit_tsv(@header);
  foreach my $row (@args) {
    $self->emit_tsv(map {
      substr($row, 0, $self->{$header[$_]});
    } 0 .. $#header);
  }
}

sub foo {
  'なにか'
}

unless (caller) {
   # 超手抜き。 '--' が出るまでを new の引数に、残りを main の引数にする

   my @opts;
   while (@ARGV) {
     last if (my $o = shift) eq '--';
     push @opts, $o;
   }

   my $app = __PACKAGE__->new(@opts);
   $app->main(@ARGV);
}

1;
