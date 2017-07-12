use strict;

# ↓↓ここでクラスの要素を宣言↓↓
package CD {
  use fields qw/title artist year/;
}

# ↓↓ my変数宣言にクラスを結びつけると…
my CD $cd = +{};

# ↓↓HASH要素の参照に typo 検査が！
$cd->{title} = "bar";   # Ok

# ↓↓間違えるとコンパイルエラー
# $cd->{titleee} = "bar"; # COMPILE ERROR!


