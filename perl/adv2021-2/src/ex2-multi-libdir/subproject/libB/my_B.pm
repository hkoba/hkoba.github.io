#!/usr/bin/env perl
package my_B;
use FindBin;
use lib "$FindBin::Bin/../libC";

# ↓これを加えた途端に、A のロードが失敗するようになる
# use my_C;
1;
