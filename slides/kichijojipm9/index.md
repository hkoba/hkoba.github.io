## kichijoji.pm #9

## `俺々 Exporter` を
### <s>楽に</s> `モジュラーに` 定義したい時
#### どうしますん？

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#9`](http://hkoba.github.io/slides/kichijojipm9/)

---

## 自己紹介 `@hkoba` 

* 個人事業主 <div style="display: inline-block; text-align: right; width: 13em; margin-left: auto;">⇔主に<a href="https://www.ssri.com/recruit/opbu/"><img style="box-shadow: none; margin: 0 5px;" src="ssri_logo.gif" alt=SSRI></a>さんのお仕事</div>
  * Perl 書きたいプログラマ、募集中

---

### perl5 の <small>(広義の)</small> Exporter の話です

```
use Carp;                  # 以後 carp() と書くだけで Carp::carp() を呼べる
```

```
use strict;                # プログラムの検査を厳格に
use warnings;              # 落とし穴には警告を出す
use lib "./lib";           # @INC に "./lib" を加える

package MyApp {
  use parent "MyParent";   # "MyParent" モジュールをロードして @ISA に
}
```

#### …特に… <!-- .element: class="fragment" -->

<h3 class="fragment" >Exporter だって<code>ニコイチ</code>したい！ </h3>

<h4 class="fragment" >だって `Class Builder` 楽に作りたいし！</h4>

#### という話です <!-- .element: class="fragment" -->


---

## あらすじ

1. Exporter のおさらい
2. Exporter を書く時に悩むこと
3. 解決策の提案


---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

## 1. Exporter おさらい


---

## Exporter とは(広義)

* `use` することで  
  <small>(use する側のパッケージに)</small>
* `コンパイルの途中`で
* 関数や変数を加える、などの変更を加えてくれる
* モジュール、のこと。
* 代表例： `Exporter.pm`, `lib.pm`, `strict.pm`

export(輸出)、import(輸入)

---

### 例：Exporter を作る

```perl
package MyUtil {

  use Exporter qw/import/;

  our @EXPORT_OK = qw/foo $bar @baz/;
  
  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = ('BAZ');

} 1;
```

* `import` 関数を用意する
  * (ここでは Exporter.pm から拝借)
* `foo`, `$bar`, `@baz` 3つを (use 出来るよう) 公開する

---

### 例：この Exporter を使う

```perl
use MyUtil qw/foo $bar @baz/;  # 以後 foo(), $bar, @baz が使えるようになる

print foo(), $bar, @baz;

# ↓以下と等価

print MyUtil::foo(), $MyUtil::bar, @MyUtil::baz;

```

---

### `use` の働き

```perl
use MyUtil qw/foo $bar @baz/;

# ↓と等価

BEGIN {
  require MyUtil;
  import MyUtil qw/foo $bar @baz/
}
```

* `MyUtil->import()` が呼ばれる
* `BEGIN { }` の中なので、即座に、先に実行される。
* `コンパイル途中`で、ここだけ先に実行される

---

### コンパイルの途中、が大事

* 例えば typo 検査はコンパイル時  
  <small>(どころか `yylex` の中！)</small>
* 記号表に変数を足すにはコンパイル後では手遅れ
* ∴コンパイルの途中で即座に実行される、  
 `BEGIN {...}` が必要

---

#### 『use する側のパッケージ』を perl で知る方法

<h4 class="fragment"><code>caller</code>を使う</h4>


```perl
package Bar {
  sub import {
    my ($class, @args) = @_;

    my $callpack = caller;
    print "$class is used from $callpack\n";

    my $newname = $callpack."::bar";
    print "Installing $newname...\n";

    no strict 'refs';
    *{$newname} = sub { "BAR" };
  }
} 1;
```

```sh
% perl -Isrc3 -le 'use Bar; print bar()'
```

---

### 例：クラスを生やす Exporter

```perl
sub import {
  
}
```

---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

## 2. Exporter 書く時の悩み

## ニコイチできない  <!-- .element: class="fragment" -->

---

### 例えば…

`use 自作モジュールX;` だけで

* 関数の取り込み  
  <small>Exporter.pm みたいに…</small>
* `@ISA` (親クラス) の設定  
  <small>parent.pm みたいに…</small>
* `use strict; use warnings ...` も on  
  <small>Mojo::Base.pm みたいに…</small>

にしたい。

---

### 組み合わせたら？

```perl
package MyUtil2 {
  ... # 全部 require して

  sub import {
    my ($class, @args) = @_;

    strict  ->import();
    warnings->import();
    parent  ->import();
    Exporter->import(@args);
  }

  our @EXPORT_OK = qw/baz/;
  sub baz { "BAZ" }

} 1;
```

---

```sh
% perl -le 'use MyUtil2; print $unknown_var'
```

strict.pm → ◯  <!-- .element: class="fragment" -->

```sh
% perl -le 'use MyUtil2; print undef()+undef()'
```

warnings.pm → ◯  <!-- .element: class="fragment" -->

```sh
% perl -le 'use MyUtil2; print @main::ISA'
```

parent.pm → ✕  <!-- .element: class="fragment" -->


```sh
% perl -e 'use MyUtil2 qw/baz/; print baz()'
```

Exporter.pm → ✕  <!-- .element: class="fragment" -->

---

### strict.pm, warnings.pm → ◯

#### 効くように最初から設計されているから
#### `$^H` の save/restore 範囲を上手く設計してあるから

---

### parent.pm, Exporter.pm → ✕

<h3 class="fragment"><code>caller</code> が変わるから</h3>

```perl
package MyUtil3 {
  require parent;
  require Bar;

  sub import {
    my ($class, @args) = @_;
    parent ->import();
    Bar    ->import(@args);   # Bar::import() にとって、 caller は MyUtil3
  }

} 1;
```

```sh
% perl -Isrc5 -le 'use MyUtil3; print @main::ISA; print bar()'
```

___

## 余談
### `Sub::Uplevel` で

CORE::GLOBAL::caller を差し替えれば行ける?

←ダメでした。 <!-- .element: class="fragment" -->

---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

## 3. 問題の分析と解決案

---

 <!-- .slide: id="root-of-the-problem" -->

## 問題の根幹

`import` の中に処理を埋め込んでいること

```perl
sub import {
  my $callpack = caller;
  ... do real job ...
}
```

↓分けるべき(最低限)

```perl
sub import {
  shift->real_job(scalar caller, @_);
}

sub real_job {
  my ($class, $callpack, @args);
  ... do real job ...
}
```

<h4 class="fragment">既存のモジュールは、ほぼ <code>全滅</code></h4>

---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

### 既存のモジュールは、ほぼ全滅！
### だから <!-- .element: class="fragment" -->
## `これから` <!-- .element: class="fragment" -->
### の話をしましょう <!-- .element: class="fragment" -->


---

### importの分離だけじゃ不十分

```perl
use Carp   qw/croak/;    # 関数名

use lib    qw/lib/;      # ディレクトリ・パス名

use parent qw/Foo/;      # クラス名

use fields qw/foo bar/;  # $self の key
```

import の引数仕様レベルで、共存不能なものも多い <!-- .element: class="fragment" -->

∴共存出来る引数仕様を考えたい <!-- .element: class="fragment" -->

---

### 引数仕様の一案

```perl
use MyUtil
   qw/croak/                  # 関数名
   , [lib    => qw/lib/]      # ディレクトリ・パス名
   , [parent => qw/Foo/]      # クラス名
   , [fields => qw/bar baz/]  # $self の key
;
```

↓

```perl
MyUtil->import_symbol(__PACKAGE__, qw/croak/);

MyUtil->import_lib(__PACKAGE__,    qw/lib/);

MyUtil->import_parent(__PACKAGE__, qw/Foo/);

MyUtil->import_fields(__PACKAGE__, qw/bar baz/);
```


---

```perl
use MyUtil
   qw/croak/                  # 関数名
   , [lib    => qw/lib/]      # ディレクトリ・パス名
   , [parent => qw/Foo/]      # クラス名
   , [fields => qw/bar baz/]  # $self の key
;
```

* 文字列は `Exporter.pm` と同じ import 扱い
* `[プラグマ => 引数]` をメソッド呼び出しに変換

### ある種の、MetaObject プロトコル <!-- .element: class="fragment" style="margin-top: .5em;" -->

---

## MOP4Import

* MetaObject Protocol for `Import`


---

### まとめ

* Exporter 便利だよね〜
* 便利な Exporter 作るの面倒だよね〜
* MOP4Import みたいに mixin 化すると良いんでは？
