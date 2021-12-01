#!/usr/bin/env perl
package MyCMS::DB;
use strict;
use warnings;

use File::AddInc;

use MyCMS::Util;

sub DB { ... }

unless (caller) {
  print "This is ", __PACKAGE__, "\n";
}

1;
