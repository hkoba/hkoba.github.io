#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin;

package MyApp {
  BEGIN {
    require MOP4Import::Declare;
    my $callpack = 'MyApp';
    my $opts = MOP4Import::Declare->Opts->new([$callpack]);
    MOP4Import::Declare->declare_strict($opts, $callpack);
    MOP4Import::Declare->declare_parent($opts, $callpack, 'MyUtilX');
    MOP4Import::Declare->import_NAME($opts, $callpack, 'croak');
  }

  croak "hoehoe";
};
