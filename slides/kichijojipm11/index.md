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
$hash->{'要素参照のtypoを'}
```

コンパイル時に検出する <!-- .element: class="fragment" -->

ためのもの、デース <!-- .element: class="fragment" -->

___

<!-- .slide: class="code-big" -->

### fields を使うには
### 予め ２種類の宣言

* `use fields`
* `my 型名 $変数` 

が必要です

___

<!-- .slide: class="code-big" -->

### まず fields で
### クラスに属する要素を宣言します

```perl
package CD;

use fields
  qw/title artist year/;
```

___

<!-- .slide: class="code-big" -->

### あとは my 宣言にも型を加えます

```perl
my CD $hash = +{};
```

これで $hash に typo 検査が働きます。 <!-- .element: class="fragment" -->

___

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

#### コード例

```perl
use strict;

package CD {
  # ↓↓ここでクラス CD の要素を宣言↓↓
  use fields qw/title artist year/;
}

# ↓↓ my変数宣言にクラス CD を結びつけると…
my CD $cd = +{};

# ↓↓HASHの要素参照に typo 検査が、効くようになる
$cd->{title} = "bar";   # Ok

# ↓↓このように typo するとコンパイルエラー
# $cd->{titleee} = "bar"; # COMPILE ERROR!
```

( [demo1.pl](demo1.pl) )

___

```perl
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
```

* 保存した瞬間に、つづり間違いが分かる
* エラー箇所にカーソルが自動で飛んでくれると、  
  さらに楽ちん

---

### 本題: typo がツラいものは他にも有る

## CLI ツールのオプション<!-- .element: class="fragment" -->


---

#### 例: オプション付きの `Hello world`

* `--output=ファイル名` 指定時はファイルに出力

```perl
use Getopt::Long;

# オプション解析
my %opts;
GetOptions(\%opts, "output|o=s")
  or usage("Unknown options");

# 出力先設定
my $outfh;
if ($opts{output}) {
  open $outfh, '>', $opts{output} or die $!;
} else {
  $outfh = \*STDOUT;
}

print $outfh "Hello world!\n";
```

`$opts{output}` の output を打ち間違っても、  
只のHASH なのでコンパイルエラーには `ならない`

--

### この typo は my 変数で退治できる

`$opts{output}` → `$o_output`

```perl
use strict;
use Getopt::Long;

GetOptions("o|output=s" => \ (my $o_output))
  or usage("Unknown options");
  

# 出力先設定
my $outfh;
if ($o_output) {
  open $outfh, '>', $o_output or die $!;
} else {
  $outfh = \*STDOUT;
}
```

…ただし…


---

### 変数scope広すぎ問題は、残る

```perl
GetOptions("o|output=s" => \ (my $o_output))
  or usage("Unknown options");

# 出力先設定
my $outfh;
if ($o_output) {
  open $outfh, '>', $o_output or die $!;
} else {
  $outfh = \*STDOUT;
}
```

→サブルーチン化する時、困る<!-- .element: class="fragment" -->

例えば: 出力先設定のサブルーチン化<!-- .element: class="fragment" -->


---

### 悪いサブルーチン化の例

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

<small>入力`$o_output` が暗黙渡し,  出力 `$outfh` も暗黙返し</small>

* setup_outfh `以外の関数も` 参照・更新するかも？
* `ソースを全部読まないと` 分からない
* 他人がメンテ出来ない

---


### 引数と戻り値を明示したコード

```perl
my $outfh = setup_outfh(
  $o_output  # ←←←←←←←←←←←  XXX
);

sub setup_outfh {
  my ($o_output) = @_;   # ←←←←←← YYY

  if ($o_output) {
    open my $outfh, '>', $o_output or die $!;
    return $outfh;
  } else {
    return \*STDOUT;
    # $outfh = \*STDOUT; # ←←←←←← ZZZ
  }
}
```

→でも、外側の $o_output や $outfh が  
`setup_outfh の中まで` **伝わっていること** は残る

---

<!-- .slide: class="ul-small" -->

```perl
my $outfh = setup_outfh(
  $o_output  # ←←←←←←←←←←←  XXX
);

sub setup_outfh {
  my ($o_output) = @_;   # ←←←←←← YYY

  if ($o_output) {
    open my $outfh, '>', $o_output or die $!;
    return $outfh;
  } else {
    return \*STDOUT;
    # $outfh = \*STDOUT; # ←←←←←← ZZZ
  }
}
```

* XXX: 引数を渡し忘れたり
* YYY: 引数を受け忘れたり
* ZZZ: 代入を return に書き換え忘れたり

### コンパイル時エラーにはならない！

( [demo3.pl](demo3.pl) )

---

### fields で置換え

* `$o_output` → `$opts->{output}`
* `$outfh` → `$opts->{_outfh}`

```perl
use strict;
use Getopt::Long;

package Opts {
  use fields qw/output _outfh/;
}

{
  my Opts $opts = +{}; # (bless するのも有り)

  GetOptions("o|output=s" => \ $opts->{output})
    or usage("Unknown options");
    
  setup_outfh($opts); ...
}

sub setup_outfh {...}
```

___

これもあり

```perl
{
  my Opts $opts = fields::new('Opts');

  GetOptions($opts, "output|o=s")
    or usage("Unknown options");
    
  setup_outfh($opts);
}
```

---

### setup_outfh の中身


```perl
sub setup_outfh {

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

### (main) と setup_outfh が、別スコープに！

```perl
{
  my Opts $opts = +{};

  ...
  setup_outfh($opts);
}

sub setup_outfh {
  (my Opts $opts) = @_;
  ...
}
```

引数・戻り値として渡したものだけが、  
参照・操作対象であることを、  
`Perl が保証してくれる`。

( [demo4.pl](demo4.pl) )


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
