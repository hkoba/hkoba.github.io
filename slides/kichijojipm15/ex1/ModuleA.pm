#!/usr/bin/env perl
package ModuleA;
use strict;
use warnings;
use fields qw/rowList columnList columnDict/;
sub MY () {__PACKAGE__}

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

sub main {
  my ($class, @args) = @_;

  my $obj = $class->new;

  $obj->do_something($class->parse_args(@args));

  print $obj->as_string, "\n";

}

unless (caller) {

  __PACKAGE__->main(@ARGV);

}

1;
