#!/usr/bin/env perl
use strict;
use Getopt::Long;

package Opts {
  use fields qw/output/;
}

# main 相当の処理
{
  my Opts $opts = fields::new('Opts');

  GetOptions($opts, "output|o=s")
    or usage("Unknown options");

  my $outfh = prepare_outfh($opts);

  print $outfh "Hello world!\n";
}

# 以下、サブルーチン
sub prepare_outfh {
  (my Opts $opts) = @_;
  if ($opts->{output}) {
    open my $outfh, '>', $opts->{output} or die $!;
    return $outfh;
  } else {
    return \*STDOUT;
  }
}

sub usage {
  die <<END;
Usage: $0 [--output=OUTPUT_FILENAME]

Yet another hello world!
END
}
