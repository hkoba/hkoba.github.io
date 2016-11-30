package MyUtilX {
  use MOP4Import::Declare -as_base;

  sub import {
    my ($myPack, @args) = @_;

    my $opts = $myPack->Opts->new([caller]);

    $myPack->dispatch_declare($opts, $opts->{destpkg}
                              , -strict                # use strict
                              , [parent => $myPack]    # use parent MyUtilX
                              , @args);                # Exporter.pm +α
  }

  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = "BAZ";

} 1;
