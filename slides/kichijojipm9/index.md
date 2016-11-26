## kichijoji.pm #9

## 俺々 `Exporter` を
### 楽に定義したい時
### どうしますん？

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
Twitter: **@hkoba**  

___

## スライド URL:

[hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#9`](http://hkoba.github.io/slides/kichijojipm9/)

---

## 自己紹介 `@hkoba` 

* 個人事業主 <div style="display: inline-block; text-align: right; width: 13em; margin-left: auto;">⇔主に<a href="https://www.ssri.com/recruit/opbu/"><img style="box-shadow: none; margin: 0 5px;" src="ssri_logo.gif" alt=SSRI></a>さんのお仕事</div>
  * Perl 書きたいプログラマ、募集中

---

## あらすじ

* (perl5 の) Exporter のおさらい
* Exporter を書く時に悩むこと
* `て` `い` `あ` `ん`

---

## 一番の問題意識

### Exporter だって『ニコイチ』したい！ <!-- .element: class="fragment" -->
### したくない？ <!-- .element: class="fragment" -->

---

## Exporter とは

* `use` することで
  * (use する側のパッケージに)
* 関数や変数を加える、などの変更を加えてくれる
* モジュール、のこと。
* 代表例： `Exporter.pm`, `lib.pm`, `strict.pm`

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

___

### Exporter の呼び方のバリエーション

```perl
use MyUtil qw/foo $bar @baz/;  # 欲しい物だけ import

use MyUtil;                    # @EXPORT に書かれた全てを import

use MyUtil ();                 # import を呼ばない
```

___

### Exporter でバージョン検査

```perl
use MyUtil 0.5;
```

* この話はしません(使ったこと無い…)

---

### `use` の働き

```perl
use MyUtil qw/foo $bar @baz/;

# ↓と等価

BEGIN { require MyUtil; import MyUtil qw/foo $bar @baz/ }
```

* `MyUtil->import()` が呼ばれる
* `BEGIN { }` の中なので、先に実行される。
* 以後の行のコンパイルに作用できる。

___

特例：

```perl
use MyUtil ();                 # import を呼ばない

# ↓と等価

BEGIN { require MyUtil }
```

___

### オマケ: 5.001m の exporter 一覧

```sh
% find -name \*.pm | xargs grep -l 'sub import '|sort
./ext/POSIX/POSIX.pm
./lib/AutoLoader.pm
./lib/English.pm
./lib/Env.pm
./lib/Exporter.pm
./lib/Shell.pm
./lib/integer.pm
./lib/lib.pm
./lib/sigtrap.pm
./lib/strict.pm
./lib/subs.pm
%
```

---

## (改) Exporter とは

* `import` メソッドを持つ module である

```perl
package Foo;

sub import {
  ...
}
1;
```

---

## 例: `strict.pm`

```perl
#  perl 5.001m から抜粋
package strict;

sub import {
    shift;
    $^H |= bits(@_ ? @_ : qw(refs subs vars));
}

sub bits {
    my $bits = 0;
    foreach $sememe (@_) {
        $bits |= 0x00000002 if $sememe eq 'refs';
        $bits |= 0x00000200 if $sememe eq 'subs';
        $bits |= 0x00000400 if $sememe eq 'vars';
    }
    $bits;
}
```

---

### まとめ

* Exporter 便利だよね〜
* 便利な Exporter 作るの面倒だよね〜
* MOP4Import みたいに mixin 化すると良いんでは？
