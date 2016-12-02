package AddInnerClass {
  use MOP4Import::Declare::Type -as_base;
  sub import {
    my ($myPack, $innerName, $parent) = @_;

    my $opts = $myPack->Opts->new([caller]);

    $myPack->declare_type($opts, $opts->{destpkg}, $innerName
                          , [parent => $parent]);
  }
} 1;
