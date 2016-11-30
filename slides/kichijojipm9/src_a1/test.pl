#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin;

use MyUtilX qw/foo $bar @baz/;

print "ISA: ", our @ISA, "\n";
print foo(), $bar, @baz, "\n";
