#!/usr/bin/env perl
package MyCMS;
use strict;
use warnings;

# ↓この２行が無いと、このディレクトリ以下の他のモジュールを use 出来ない
use FindBin;
use lib $FindBin::Bin;

use MyConfig;
use MyCMS::DB;

unless (caller) {
  print "This is ", __PACKAGE__, "\n";
}

1;
