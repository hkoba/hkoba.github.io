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

* Exporter とは
  * (hkoba 定義)
* Exporter 作者の悩みどころ
* `て` `い` `あ` `ん`

---

## Exporter とは

* `use` することで
  * (use する側のパッケージに)
* 関数や変数を加える、などの変更を加えてくれる
* モジュール、のこと。
* 代表例： `Exporter.pm`, `lib.pm`, `strict.pm`

---

### 例：Exporter.pm で Exporter (MyUtil)を作る

```perl
package MyUtil {

  use Exporter qw/import/;

  our @EXPORT_OK = qw/foo $bar @baz/;
  
  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = ('BAZ');

}
1;
```

---

### use で import する

```perl
use MyUtil qw/foo $bar @baz/;

print foo(), $bar, @baz;

# ↓以下と等価

print MyUtil::foo(), $MyUtil::bar, @MyUtil::baz;

```

---

### Exporter の呼び方のバリエーション

```perl
use MyUtil qw/foo $bar @baz/;  # 欲しい物だけ import
use MyUtil;                    # @EXPORT に書かれた全てを import
use MyUtil ();                 # import を呼ばない
```



---

### `use` の働き

```perl
use MyUtil qw/foo $bar @baz/;  # 欲しい物だけ import

# ↓と等価

BEGIN { require MyUtil; import MyUtil qw/foo $bar @baz/ }
```

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

* import を定義してある module.

```perl
package Foo;

sub import {
  ...
}
1;
```

---

### まとめ

* Exporter 便利だよね〜
* 便利な Exporter 作るの面倒だよね〜
* MOP4Import みたいに mixin 化すると良いんでは？
