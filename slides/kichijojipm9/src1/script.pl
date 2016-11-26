#!/usr/bin/perl -l
use FindBin;
use lib $FindBin::Bin;

use MyUtil qw/foo $bar @baz/;

print foo(), $bar, @baz;

# ↓以下と等価

print MyUtil::foo(), $MyUtil::bar, @MyUtil::baz;
