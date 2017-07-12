## fields は
### CLI ツールに使っても
### ええんやで

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba**

[hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#11`](http://hkoba.github.io/slides/kichijojipm11/)

---

<!-- .slide: class="code-big" -->

#### おさらい: `fields` とは

```perl
$hash->{'ここのtypoを'}
```

コンパイル時に検出する <!-- .element: class="fragment" -->

ためのもの、デース <!-- .element: class="fragment" -->

---

<!-- .slide: class="code-big" -->

### fields を使うには
### 予め ２種類の宣言

* `use fields`
* `my 型名 $変数` 

が必要です

---

<!-- .slide: class="code-big" -->

### まず fields で
### クラスに属する要素を宣言します

```perl
package CD;

use fields
  qw/title artist year/;
```

---

<!-- .slide: class="code-big" -->

### あとは my 宣言にも型を加えます

```perl
my CD $hash = +{};
```

これで $hash に typo 検査が働きます。 <!-- .element: class="fragment" -->

---

<!-- .slide: class="code-big" -->

### OK
```perl
say $hash->{title};
```

### COMPILE ERROR!
```perl
say $hash->{titleee};
```

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

( [demo1.pl](demo1.pl) )

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

#### 本題: typo がツラいものは他にも有る

### CLI ツールのオプション<!-- .element: class="fragment" -->


---

```perl
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts, "output|o=s")
  or usage("Unknown options");

my $outfh;
if ($opts{output}) {
  open $outfh, '>', $opts{output} or die $!;
} else {
  $outfh = \*STDOUT;
}

print $outfh "Hello world!\n";
```

`$opts{output}` …打ち間違ったらツラい

--

* ツラい時は my 変数を使う。

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

( [demo3.pl](demo3.pl) )

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

___

これもあり

```perl
{
  my Opts $opts = fields::new('Opts');

  GetOptions($opts, "output|o=s")
    or usage("Unknown options");
    
  setup($opts);
}
```

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

( [demo4.pl](demo4.pl) )

___

### 依然、グローバル状態に依存。されど…

* 一個のハッシュ表 `$opts` に閉じ込めることが出来た。
* `$opts` を渡した sub だけが、書き換えを行える。
* オプション名の typo は `コンパイル時に検出` される



---


### まとめ

* fields → `コンパイル時` に typoを検出
  * IDE からのコード検査に最適
* `CLIのオプションにも` fields は役に立つよ〜
* main とサブルーチン, `スコープ絶縁` しつつ  
`strict` 検査



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
