#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;

use ModuleA;
my $obj = ModuleA->new;

$obj->do_something([1, x => 3], [1, y => 8], [1, z => 3], [2, z => 1], [2, x => 1]);
print $obj->as_string, "\n";
