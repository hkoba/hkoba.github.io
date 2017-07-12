use strict;

package CD {
  # ↓↓ここでクラス CD の要素を宣言↓↓
  use fields qw/title artist year/;
}

# ↓↓ my変数宣言にクラス CD を結びつけると…
my CD $cd = +{};

# ↓↓HASH要素の参照に typo 検査が、効く
$cd->{title} = "bar";   # Ok

# ↓↓このように typo するとコンパイルエラー
# $cd->{titleee} = "bar"; # COMPILE ERROR!



