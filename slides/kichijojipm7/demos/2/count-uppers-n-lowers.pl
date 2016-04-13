#!/usr/bin/env perl
use strict;
use warnings;

my ($uppers, $lowers) = (0, 0);

while (<>) {
  chomp;

  $uppers += tr!A-Z!!;
  $lowers += tr!a-z!!;
}

print join("\t", "uppers:$uppers", "lowers:$lowers"), "\n";
