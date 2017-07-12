use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts, "output|o=s")
  or usage("Unknown options");

my $outfh;
if ($opts{output}) {
  open $outfh, '>', $opts{output} or die $!;
} else {
  $outfh = \*STDOUT; # ←←←←←← YYY
}

print $outfh "Hello world!\n";
