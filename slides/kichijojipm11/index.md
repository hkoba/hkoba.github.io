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

### 例: オプション付きの `Hello world`

* `--output=ファイル名` 指定時はファイルに出力

---

#### 例: オプション付きの `Hello world`

* `--output=ファイル名` 指定時はファイルに出力

```perl
use Getopt::Long;

# オプション解析
my %opts;
GetOptions(\%opts, "output|o=s")
  or usage("Unknown options");

# 出力先を $outfh へ設定
my $outfh;
if ($opts{output}) {
  open $outfh, '>', $opts{output} or die $!;
} else {
  $outfh = \*STDOUT;
}

print $outfh "Hello world!\n";
```

---

### 問題

`%opts` が素の HASH なので `output` を打ち間違っても  
コンパイルエラーに `ならない`

```perl
# オプション解析
my %opts;
GetOptions(\%opts, "output|o=s")
  or usage("Unknown options");

# 出力先を $outfh へ設定
my $outfh;
if ($opts{output}) {
  open $outfh, '>', $opts{output} or die $!;
} else {
  $outfh = \*STDOUT;
}

print $outfh "Hello world!\n";
```

オプションを[個別の my 変数に変えて](#my_scalar_option) typo 検査を
効かせる方法もあります。が… `そこを fields で` ！

---

### fields による改良案(1/2)

( [demo4.pl](demo4.pl) )

```perl
package Opts {
  use fields qw/output/; # まずクラスの要素を宣言
}

# main 相当の処理
{
  my Opts $opts = fields::new('Opts'); # 次にmy変数を型付きで宣言

  GetOptions($opts, "output|o=s")
    or usage("Unknown options");

  my $outfh = prepare_outfh($opts);

  print $outfh "Hello world!\n";
}

# 以下、サブルーチン
```

---

### 改良案、続き(2/2)


```perl
sub prepare_outfh {
  (my Opts $opts) = @_;

  if ($opts->{output}) {
    open my $outfh, '>', $opts->{output} or die $!;
    return $outfh;

  } else {
    return \*STDOUT;
  }
}
```

ほとんど、メソッド定義

( [demo4.pl](demo4.pl) )

---

### 何が嬉しいか

* オプションのtypoをコンパイル時に検出できる
* サブルーチンの変数スコープを (main) と分離出来る

引数・戻り値だけが参照・操作対象であることを  
`Perl が保証してくれる`

( [demo4.pl](demo4.pl) )


---

### 他のアプローチとの比較
#### (時間がないので省略)

___

 <!-- .slide: id="my_scalar_option" -->

### $opts{output} の typo は my 変数で退治できる

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


___

### 変数scope広すぎ問題は、残る

→サブルーチン化する時、困る<!-- .element: class="fragment" -->

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

例えば: 出力先設定のサブルーチン化

___

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

___


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

___

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

### まとめ

* fields → `コンパイル時` に typoを検出
  * エディタ・IDE 保存時のコード検査に最適
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
