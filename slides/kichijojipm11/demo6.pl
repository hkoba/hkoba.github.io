#!/usr/bin/env perl
use strict;

package Opts;
use Getopt::Long;

BEGIN {
  our %FIELDS = (
    output => [s => 'o']
  );
}
{
  my Opts $opts = +{};

  GetOptions($opts, make_opts(\ our %FIELDS))
    or usage("Unknown options");

  my $outfh = prepare_outfh($opts);

  print $outfh "Hello world!\n";
}

sub prepare_outfh {
  (my Opts $opts) = @_;
  if ($opts->{output}) {
    open my $outfh, '>', $opts->{output} or die $!;
    return $outfh;
  } else {
    return \*STDOUT;
  }
}

sub make_opts {
  my ($fields) = @_;
  map {
    my ($type, @alias) = @{$fields->{$_}};
    join("=", join("|", $_, @alias), $type);
  } keys %$fields;
}

sub usage {
  die <<END;
Usage: $0 [--output=OUTPUT_FILENAME]

Yet another hello world!
END
}
