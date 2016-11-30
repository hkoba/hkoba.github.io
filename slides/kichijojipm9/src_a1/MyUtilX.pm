package MyUtilX {
  use MOP4Import::Declare -as_base;

  sub import {
    my ($myPack, @args) = @_;

    my $opts = $myPack->Opts->new([caller]);

    $myPack->declare_strict($opts, scalar caller); # use strict

    $myPack->declare_parent($opts, scalar caller, $myPack); # use parent MyUtilX

    $myPack->dispatch_declare($opts, scalar caller, @args); # Exporter.pm +α
  }

  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = "BAZ";

} 1;
