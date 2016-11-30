#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin;

package Bar {
  use MOP4Import::Declare -as_base
    , -strict
    , [parent => 'MyUtilX']
    , qw/croak/;

  croak "hoehoe";
};
