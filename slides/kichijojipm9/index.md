## kichijoji.pm #9

## `俺々 Exporter` を
### <s>楽に</s> `モジュラーに` 定義したい時
#### どうしますん？

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#9`](http://hkoba.github.io/slides/kichijojipm9/)

---

## 自己紹介 `@hkoba` <img src="img/myfistrect.jpg" style="margin-top: 0px; margin-bottom: 0px; width: 64px; height: 64px">

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

### 例：典型的な Exporter の作り方

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
print foo(), $bar, @baz; # XXX: $bar, @baz がコンパイルエラー
```

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

* 例えば変数名の typo 検査はコンパイル時！  
  <small>(どころか `yylex` の中！)</small>
* <small>記号表に変数を足すには</small>コンパイル後では手遅れ
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

### Class Generator の例 `AddInnerClass`

こんな↓ Foo があるとして

```perl
package Foo {
  sub foo { "FOO" }
} 1;
```

Foo を継承した内部クラスを生やす exporter を作りたい

```perl
package MyApp {
  use AddInnerClass Bar => 'Foo'; # MyApp::Bar を生やす。親は Foo.

  print MyApp::Bar->foo, "\n";
};
```

---

### AddInnerClass の実装例

```perl
package AddInnerClass {
  sub import {
    my ($class, $innerName, $parent) = @_;

    my $callpack = caller;

    require "$parent.pm"; # XXX: 手抜き

    my $isa = do {
      my $isa_sym = globref($callpack, $innerName, 'ISA');
      *{$isa_sym}{ARRAY} // do {
        *$isa_sym = my $array = [];
        $array;
      };
    };
    push @$isa, $parent;
  }
```

(続)

___

### globref() の実装例

```perl
  sub globref {
    my $name = join "::", @_;
    no strict 'refs';
    \*{$name};
  }
} 1;
```

`no strict 'refs'` を局所化出来て便利。

---



---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

## 2. Exporter 書く時の悩み

## ニコイチできない  <!-- .element: class="fragment" -->

---

### 例えば…

自作モジュール MyUtilX を `use MyUtilX;` するだけで

* 関数の取り込み  
  <small>Exporter.pm みたいに…</small>
* `@ISA` (親クラス) の設定  
  <small>parent.pm みたいに…</small>
* `use strict; use warnings ...` も on  
  <small>Mojo::Base.pm みたいに…</small>

になるような exporter を作りたい。  
既存の exporter の `組み合わせで` 作りたい。

---

### 組み合わせたら？

```perl
package MyUtilX {
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
% perl -le 'use MyUtilX; print $unknown_var'
```

strict.pm → ◯  <!-- .element: class="fragment" -->

```sh
% perl -le 'use MyUtilX; print undef()+undef()'
```

warnings.pm → ◯  <!-- .element: class="fragment" -->

```sh
% perl -le 'use MyUtilX; print @main::ISA'
```

parent.pm → ✕  <!-- .element: class="fragment" -->


```sh
% perl -e 'use MyUtilX qw/baz/; print baz()'
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
package MyUtilX {
  require parent;
  require Bar;

  sub import {
    my ($class, @args) = @_;
    parent ->import();
    Bar    ->import(@args);   # Bar::import() にとって、 caller は MyUtilX
  }

} 1;
```

```sh
% perl -Isrc5 -le 'use MyUtilX; print "ISA: ", @main::ISA; print bar()'
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


---

### import と実処理は分けるべき(最低限)

```perl
sub import {
  shift->real_job(scalar caller, @_);
}
```

```perl
sub real_job {
  my ($class, $callpack, @args);
  ... do real job ...
}
```

<h4 class="fragment">既存のモジュールは、ほぼ <code>全滅</code></h4>

---

<!-- .slide: class="lead" data-background-color="#C0F0B6" -->

#### 既存のモジュールは、ほぼ全滅！ だから…

<h3 class="fragment"><code>これから</code>の話をしましょう</h3>


---

### 提案：望ましいExporter 実装のあり方

* import には caller取得 + dispatch だけ
* 処理本体を別メソッドとして公開


---

### 私からの実装例: `MOP4Import::Declare`

* MetaObject Protocol for `import`
* `declare` style.

---

```perl
package MyUtilX {
  use MOP4Import::Declare -as_base;

  sub import {
    my ($myPack, @args) = @_;

    my $opts = $myPack->Opts->new([caller]);

    $myPack->declare_strict($opts, scalar caller);          # use strict

    $myPack->declare_parent($opts, scalar caller, $myPack); # use parent MyUtilX

    $myPack->dispatch_declare($opts, scalar caller, @args); # Exporter.pm +α
  }
```

```perl
  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = "BAZ";

} 1;
```

---

### MyUtilX を使う側

```perl
use MyUtilX qw/foo $bar @baz/;

print "ISA: ", our @ISA, "\n";  # => ISA: MyUtilX
print foo(), $bar, @baz, "\n";  # => FOOBARBAZ
```



---

### まとめ

* Exporter 便利だよね〜
* 便利な Exporter 作るの面倒だよね〜
* import と実処理を分ければモジュラーに出来るからオススメ
