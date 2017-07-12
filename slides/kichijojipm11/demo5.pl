#!/usr/bin/env perl
use strict;
use Getopt::Long;

package Opts {
  use fields qw/output _outfh/;
}

{
  my Opts $opts = fields::new('Opts');

  GetOptions($opts, "output|o=s")
    or usage("Unknown options");

  $opts->setup_outfh;

  print {$opts->{_outfh}} "Hello world!\n";
}

sub Opts::setup_outfh {
  (my Opts $opts) = @_;
  if ($opts->{output}) {
    open $opts->{_outfh}, '>', $opts->{output} or die $!;
  } else {
    $opts->{_outfh} = \*STDOUT;
  }
}

sub usage {
  die <<END;
Usage: $0 [--output=OUTPUT_FILENAME]

Yet another hello world!
END
}
