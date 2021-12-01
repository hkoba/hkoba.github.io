#!/usr/bin/env perl
package my_A;
use FindBin;
use lib "$FindBin::Bin/../subproject/libB";

use my_B;
1;
