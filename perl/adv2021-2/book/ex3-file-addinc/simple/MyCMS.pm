#!/usr/bin/env perl
package MyCMS;
use strict;
use warnings;

use File::AddInc;

use MyConfig;
use MyCMS::DB;

unless (caller) {
  print "This is ", __PACKAGE__, "\n";
}

1;
