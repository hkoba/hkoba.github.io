#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

use Cat;

my $cat = Cat->new(name => 'Daisy', birth_year => 2000);

print $cat->name, " ", $cat->age, "\n";

#-----------

package MyCat {
  use Cat -as_base;
};
