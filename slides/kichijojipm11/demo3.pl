use strict;
use Getopt::Long;

GetOptions("o|output=s" => \ (my $o_output))
  or usage("Unknown options");


my $outfh = setup_outfh(
  $o_output  # ←←←←←←←←←←←  XXX
);

sub setup_outfh {
  my ($o_output) = @_;   # ←←←←←← XXX

  if ($o_output) {
    open my $outfh, '>', $o_output or die $!;
    $outfh;
  } else {
    \*STDOUT;
    # $outfh = \*STDOUT; # ←←←←←← YYY
  }
}
