use strict;

package CD {
  # ↓↓ここで宣言↓↓
  use fields qw/title artist year/;
}

# ↓↓ my変数宣言にクラスを結びつけると…
my CD $cd = +{};

# HASH要素の参照に typo 検査が！
$cd->{title} = "bar";   # Ok

# $cd->{titleee} = "bar"; # COMPILE ERROR!



