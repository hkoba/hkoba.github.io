#!/usr/bin/env perl
package MyCMS::DB;
use strict;
use warnings;

# ↓この２行が無いと、このディレクトリ以下の他のモジュールを use 出来ない
use FindBin;
use lib "$FindBin::Bin/../";

use MyCMS::Util;

sub DB { ... }

unless (caller) {
  print "This is ", __PACKAGE__, "\n";
}

1;
