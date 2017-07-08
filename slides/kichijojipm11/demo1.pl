use strict;

package CD {
  use fields qw/title artist year/; # ←←← ここで宣言
}

my CD $cd = +{}; # ←←←変数宣言にクラスを結びつけると…

$cd->{title} = "bar";   # Ok
# $cd->{titleee} = "bar"; # COMPILE ERROR!
