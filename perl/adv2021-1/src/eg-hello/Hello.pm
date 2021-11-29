#!/usr/bin/env perl
package Hello;

sub run {
  print "Hello world!\n";
}

run() unless caller;

1;
