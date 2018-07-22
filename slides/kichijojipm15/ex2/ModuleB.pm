#!/usr/bin/env perl
package ModuleB;
use strict;
use warnings;
use fields qw/rowList columnList columnDict/;
sub MY () {__PACKAGE__}
use Data::Dumper;
use JSON;

sub new {
  my $class = shift;
  bless {rowList => [], columnList => [], columnDict => +{}}, $class;
}

sub foo {
  'なにか'
}

sub as_string {
  (my MY $self) = @_;
  join("\n", join("\t", '#' => @{$self->{columnList}}), map {
    join("\t", map {$_ // ''} @$_);
  } @{$self->{rowList}});
}

sub do_something {
  (my MY $self, my @records) = @_;
  foreach my $rec (@records) {
    my ($id, $colName, $value) = @$rec;
    if (not @{$self->{rowList}} or $self->{rowList}[-1][0] ne $id) {
      push @{$self->{rowList}}, [$id];
    }
    $self->{rowList}[-1][$self->intern_column($colName)] = $value
  }
  $self;
}

sub intern_column {
  (my MY $self, my $colName) = @_;
  $self->{columnDict}{$colName} // do {
    push @{$self->{columnList}}, $colName;
    $self->{columnDict}{$colName} = @{$self->{columnList}};
  };
}

sub parse_args {
  shift;
  map {
    [split /[:=,]/, $_, -1]
  } @_;
}

unless (caller) {
  my $obj = __PACKAGE__->new;

  my $method = shift @ARGV; # XXX: 手抜き

  my $res = [$obj->$method(@ARGV)];

  print Data::Dumper->new([$res])->Terse(1)->Indent(0)->Dump, "\n";
}

1;
