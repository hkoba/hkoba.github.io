#!/usr/bin/env perl
package my_B;

# 以下は use File::AddInc qw($libdir); と同じ
use File::AddInc [libdir_var => qw($libdir)];

use lib "$libdir/../libC";

# ↓これがあっても大丈夫
use my_C;
1;
