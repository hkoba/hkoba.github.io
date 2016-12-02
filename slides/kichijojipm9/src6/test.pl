#!/usr/bin/env perl
use strict;
use FindBin;
use lib $FindBin::Bin;

package MyApp {
  use AddInnerClass Bar => 'Foo';

};

print MyApp::Bar->foo, "\n";

# DEBUG_MOP4IMPORT=1 ./test.pl
