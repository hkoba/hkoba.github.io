## fields は
### CLI ツールに使っても
### ええんやで

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#11`](http://hkoba.github.io/slides/kichijojipm11/)

---

#### `fields.pm`
### おさらい

```perl
use strict;

package CD {
  use fields qw/title artist year/; # ←←← ここで宣言
}

my CD $cd = +{}; # ←←←変数宣言にクラスを結びつけると…

$cd->{title} = "bar";   # Ok
$cd->{titleee} = "bar"; # COMPILE ERROR!
```

( `デモ` するよ)

---


```perl
use strict;

package CD {
  use fields qw/title artist year/; # ←←← ここで宣言
}

my CD $cd = +{}; # ←←←変数宣言にクラスを結びつけると…

$cd->{title} = "bar";   # Ok
$cd->{titleee} = "bar"; # COMPILE ERROR!
```

* **実行前にエラーが** 分かって嬉しい！
* flycheck とかで **Save 時検査** がオススメ


---

### typo がツラいものは他にも有る

* コマンド行オプションも、そう。
* 普通は my 変数を使う

```perl
use strict;
use Getopt::Long;

GetOptions("o|output=s" => \ (my $o_output))
  or usage("Unknown options");
  

my $outfh;
if ($o_output) {
  open $outfh, '>', $o_output or die $!;
} else {
  $outfh = \*STDOUT;
}
```


---

### my 変数でオプション、引き回しの害

```perl
GetOptions("o|output=s" => \ (my $o_output))
  or usage("Unknown options");


my $outfh;
if ($o_output) {
  open $outfh, '>', $o_output or die $!;
} else {
  $outfh = \*STDOUT;
}
```

サブルーチン化と衝突する

ex. `$outfh` 設定処理のサブルーチン化


---

### 嫌なコード

```perl
my $outfh;
setup_outfh();

sub setup_outfh {
  if ($o_output) {
    open $outfh, '>', $o_output or die $!;
  } else {
    $outfh = \*STDOUT;
  }
}
```

`$outfh` や `$o_output` が丸見え

* 誰が、いつ、書き換えてるか分からない！


---


### 正しいけど、自己満足臭いコード

```perl
my $outfh = setup_outfh(
  $o_output  # ←←←←←←←←←←←  XXX
);

sub setup_outfh {
  my ($o_output) = @_;   # ←←←←←← XXX

  if ($o_output) {
    open my $outfh, '>', $o_output or die $!;
    $outfh;
  } else {
    # $outfh = \*STDOUT; # ←←←←←← YYY
    \*STDOUT;
  }
}
```

結局、外側の `$o_output` や `$outfh` が setup_outfh の中まで
**伝わっていること** は同じ

---


* `XXX` (の二行とも) を削っても
* `YYY` にしても

### コンパイル時エラーにはならない！


```perl
my $outfh = setup_outfh(
  $o_output  # ←←←←←←←←←←←  XXX
);

sub setup_outfh {
  my ($o_output) = @_;   # ←←←←←← XXX

  if ($o_output) {
    open my $outfh, '>', $o_output or die $!;
    $outfh;
  } else {
    # $outfh = \*STDOUT; # ←←←←←← YYY
    \*STDOUT;
  }
}
```

( `デモ` しようね)

---

### グローバル変数を fields で置換え

```perl
use strict;
use Getopt::Long;

package Opts {
  use fields qw/output _outfh/
}

{
  my Opts $opts = +{}; # (bless するのも有り)

  GetOptions("o|output=s" => \ $opts->{output})
    or usage("Unknown options");
    
  setup($opts);
}

sub setup {...}
```

* `$o_output` → `$opts->{output}`
* `$outfh` → `$opts->{_outfh}`

---

### setup の中身


```perl
sub setup {

  (my Opts $opts) = @_;

  if ($opts->{output}) {

    open $opts->{_outfh}, '>', $opts->{output} or die $!;

  } else {

    $opts->{_outfh} = \*STDOUT;

  }

}
```

もはやメソッド定義

---

### (main) と setup が、別スコープに！

```perl
{
  my Opts $opts = +{};

  ...
}

sub setup {
  (my Opts $opts) = @_;
  ...
}
```

( `デモ` しようね)

___

### 依然、グローバル状態に依存。されど…

* 一個のハッシュ表 `$opts` に閉じ込めることが出来た。
* `$opts` を渡した sub だけが、書き換えを行える。
* オプション名の typo は `コンパイル時に検出` される



---


### まとめ

* fields → `コンパイル時` に typoを検出
  * flycheck 等と併用
* `CLIのオプションにも` fields は役に立つよ〜
* main とサブルーチン, `スコープ絶縁` しつつ `strict` 検査



---

### おまけ


複数の引数書きたい時は?
```perl
my ($self, $arg1, $arg2) = @_;

# my (CLASS $self, $arg1, $arg2) = @_;  # ←←← いつもの場所には書けない

(my CLASS $self, my ($arg1, $arg2)) = @_;
```

クラス名、打つの大変な時は？
```perl
sub MY () {__PACKAGE__}    # 定数関数を定義しよう

(my MY $self) = @_;
```
