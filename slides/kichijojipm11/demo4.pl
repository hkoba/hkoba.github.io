#!/usr/bin/env perl
use strict;
use Getopt::Long;

package Opts {
  # ここでクラスOptsの要素'output'を宣言
  use fields qw/output/;
}

# main 相当の処理
{
  # Note: このスコープでは fields 未使用
  my %opts;
  GetOptions(\%opts, "output|o=s")
    or usage("Unknown options");

  my $outfh = prepare_outfh(\%opts);

  print $outfh "Hello world!\n";
}

# 以下、サブルーチン
sub prepare_outfh {
  # 次に、my変数をOpts型付きで宣言
  (my Opts $opts) = @_;

  #            ↓するとここでtypo検査が有効に！
  if ($opts->{output}) {
    #             ここも検査されます↓！
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
