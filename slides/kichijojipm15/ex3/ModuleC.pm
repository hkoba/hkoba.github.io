#!/usr/bin/env perl
package ModuleC;
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

sub cmd_do_something {
  (my MY $self, my @args) = @_;

  $self->do_something($self->parse_args(@args));

  print $self->as_string, "\n";
}

unless (caller) {
  my $obj = __PACKAGE__->new;

  my $cmd = shift || 'help';

  if (my $sub = $obj->can("cmd_$cmd")) {
    # cmd_FOO があるので、後は任せる
    $sub->($obj, @ARGV);

  } elsif ($sub = $obj->can($cmd)) {
    # 一般の任意のメソッドを試すケース
    my $res = [$sub->($obj, @ARGV)];

    # 呼び出し側で、デフォルトのシリアライザを通して出力
    print Data::Dumper->new([$res])->Terse(1)->Indent(0)->Dump, "\n";

  } else {
    $obj->cmd_help("No such command: $cmd");

  }
}

1;
