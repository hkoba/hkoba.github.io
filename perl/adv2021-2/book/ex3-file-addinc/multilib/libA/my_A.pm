#!/usr/bin/env perl
package my_A;
use File::AddInc qw($libdir);
use lib "$libdir/../subproject/libB";

use my_B;
1;
