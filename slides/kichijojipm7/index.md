## kichijoji.pm #7

#### Perl の `use strict` をもっと活かすための
### `%FIELDS`, `perl -wc`, `import` の使い方

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
本名: 小林 弘明  
Twitter: **@hkoba**  
Github: hkoba  

___

## スライド URL:

[hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#7`](http://hkoba.github.io/slides/kichijojipm7/)

---

## 自己紹介 `@hkoba` 

* 個人事業主 <div style="display: inline-block; text-align: right; width: 13em; margin-left: auto;">⇔主に<a href="https://www.ssri.com/"><img style="box-shadow: none; margin: 0 5px;" src="ssri_logo.gif" alt=SSRI></a>さんのお仕事</div>
  * Perl 書きたいプログラマ、募集中

---

## 今日お伝えしたいこと

#### それは…

__

# `%FIELDS` 便利!
### (`use fields` でもいい)

__

# `ファイル保存でperl -wc` <!-- .element: style="font-size: 80%;" -->
## この安心感！

__

# `use (import) で`  <!-- .element: style="font-size: 60%;" -->
# `クラスを生成`  <!-- .element: style="font-size: 60%;" -->
## すると、捗る！


#### の３つです。

---


### 注: 個人的に編み出した技なので


## 何をバカなことを！
### って思った人は `是非ツッコミ` を！


---

## `use fields` (fields.pm) とは <!-- .element: style="font-size: 80%" -->

* Perl 5.6 で導入 → 5.10 で現在の姿に
* クラスのインスタンス変数(field)を宣言する仕組み
* 実体はパッケージ変数 `%FIELDS`

```perl
package Cat {
  use fields qw/name birth_year/;  # 名前、生まれ年
}
```

(ほぼ) 等価なコード

```perl
package Cat {
  BEGIN {
    our %FIELDS = (name => 1, birth_year => 2);
  }
}
```

__

* 変数の型宣言と併用
```perl
my Cat $cat;
```
* コンパイル時に、静的に field の TYPO(タイポ、つづり間違い)を検知してエラーに
```perl
$cat->{namae} = 'foo';   # コンパイル時にエラー！
say $cat->{birth_yearr}; # コンパイル時にエラー！
```
* つまり `perl -wc` で検出できる

___

## `%FIELDS` 検査の実装は:

`op.c:finalize_op()`

* 検査対象： [OP_HELEM](https://github.com/Perl/perl5/blob/637494ac7ab11f737c47bf95a2c3a27ef1117984/op.c#L2497-L2533) など
  * バージョンで増減

* 検査ルーチン: blead perl だと
[op.c:S_check_hash_fields_and_hekify()](https://github.com/Perl/perl5/blob/637494ac7ab11f737c47bf95a2c3a27ef1117984/op.c#L2309)

---

#### 豆知識： `%FIELDS` 検査は
#### 実行時の変数の `内容には無関係`
### => 生HASHにすら使える

```perl
package Env {
  use fields qw/REQUEST_METHOD psgi.version/; # and so on...
};
return sub {
  (my Env $env) = @_;
  
  if ($env->{REQUEST_METHOD} eq 'GET') { # Checked!
     return [200, header(), ["You used 'GET'"]];
  }
  else {
     return [200, header()
            , ["Unsupported method"
              , "psgi.version=", $env->{'psgi.version'}]]; # Checked too!
  }
};
```

---

### `use fields` の例: クラス定義

```perl
package Cat {
 
   use fields qw/name birth_year/; # fields declaration.
 
   sub new {
      my Cat $self = fields::new(shift); #  my CLASS $var.
      $self->{name}       = shift; # Checked!
      $self->{birth_year} = shift // $self->_this_year; # Checked!
      $self;
   }
 
   sub age {
      my Cat $self = shift;
      return _this_year() - $self->{birth_year}; # Checked!
   }
   sub _this_year { (localtime)[5] + 1900 }
}
```

___

### `use fields` の例: クラスを使う側

```perl

my @cats = map {Cat->new(split ":", $_, 2)} @ARGV ? @ARGV : qw/Daisy:2010/;
 
foreach my Cat $cat (@cats) {
 
   print $cat->{name}, ": ", $cat->age, "\n";
 
   # print $cat->{namae}, "\n"; # Compilation error!
}
```


___

## Demo 1.

わざと壊して, `perl -wc` してみましょう。

---

### あなたを守るはずの fields.pm が
## 何故 `使われなかった` のか…

### 私なりの推測は…

__

<!-- .slide: id="fields-weakpoints" -->

### my に型名を書くのが面倒！

```perl
my MyModuleX $foo;
my MyModuleY $bar;
```

### 型名が長くなると、もっと辛い！

```perl
my MyProject::SomeModule::SomeClass $obj;
```

___

### 実装を露出させるのは OOP 的に邪道!

```perl
foreach my Cat $cat (@cats) {
 
   print $cat->{name}, "\n"; # 内部に直接アクセスは…

}
```

### fields.pm だけでは new も Accessor も無い！

```perl
use fields qw/name birth_year/;

__PACKAGE__->mk_accessors(qw/name birth_year/); # DRY!
```

___

<!-- .slide: id="annoying-inner-classes" -->

#### たとえ 生HASH 使えても
### 内部クラスを沢山書くのは面倒

```perl
package MyApp;
{
  package MyApp::Artist; use fields => qw/artistid name/;
}
{
  package MyApp::CD; use fields => qw/cdid artistid title year/;
}

sub print_artist_cds {
  (my $self, my MyApp::Artist $artist) = @_;
  my @cds = $self->DB->select(CD => {artistid => $artist->{artistid}});
  foreach my MyApp::CD $cd (@cds) {
    print tsv($cd->{title}, $cd->{year}), "\n";
  }
}

```


___

でも、これらへの[対策、緩和策](#/fields-workaround)は作れます

それよりも…

---

### そもそも
# `perl -wc` が
## 普及していない？

---

#### さて皆さんに `質問` です

### `perl -wc` (又は他の lint) してますか？

1. そもそも Perl を書いてない
1. 全然 (又は、知らなかった)
2. 気が向いた時
3. エディタに統合済み (**syntastic(vim)** ,  **flycheck(emacs)** ...)



---

### `perl -wc` がイマイチ普及しない
### 理由を私なりに推測すると…

---

### `perl -wc` は
## 前準備が面倒だから？

---

## `-I....` の設定が必要！

(use がコケる)

```sh
% perl -wc demos/2/foo.pl
Can't locate Foo.pm in @INC (you may need to install the Foo module)..
```

```sh
% perl -Idemos/2/lib -wc demos/2/foo.pl
demos/2/foo.pl syntax OK
```


___

### モジュールに `perl -wc` はイマイチ！

`perl -MMod -e0` の方が、
多くのエラーを見つけてくれる(ex. `require` の TYPO, `import()` のエラー...)

```sh
% perl -wc demos/2/lib/Bar.pm   
demos/2/lib/Bar.pm syntax OK
```

```sh
% perl -Idemos/2/lib -MBar -e0
Can't locate Foooo.pm in @INC (...
```

---

### そこで拙作:  [`App::perlminlint`](https://github.com/hkoba/app-perlminlint)

* `perl -wc` のラッパー
  * `-I...` などを自動で調べて補う
  * 拡張子等に応じて、検査方法を変更

___

* 使い方: `perl` の代わりに `perlminlint` を呼ぶだけ
    ```sh
    perlminlint  YOUR_SCRIPT
    ```

* 主なオプションは互換
  * `-wc` も渡せます。(既存のツールとの互換性のため)
    ```sh
    perlminlint -w -c -wc YOUR_SCRIPT
    ```

___

#### 例

```sh
% perlminlint  myscript.pl
#  => This tests "perl -wc myscript.pl"

% perlminlint  bin/myscript.pl
#  => This tests "perl -Ilib -wc myscript.pl"

% perlminlint  MyModule.pm
#  => This tests "perl -MMyModule -we0"

% perlminlint  MyInnerModule.pm
#  => This tests "perl -I.. -MMyApp::MyInnerModule -we0"

% perlminlint  cpanfile
#  => This tests Module::CPANfile->load
```

#### インストールは cpanm でおk

```sh
cpanm App::perlminlint
```

---

## デモ
### perlminlint を `ファイル保存時` に呼ぶ

___

#### Emacs の flycheck の場合

設定例が同梱:
([flycheck-perlminlint](https://github.com/hkoba/app-perlminlint/tree/master/flycheck-perlminlint))

```elisp
(flycheck-set-checker-properties
      'perl
      '((flycheck-command "perlminlint" source-original)))
```

___

#### Vim の syntastic の場合(多分)

```vim
let g:syntastic_perl_perl_exec = 'perlminlint'
```

---

### **ただし！** `トロイの木馬` には注意

perlminlint は (perl -wc と同じく)  
`テスト対象コードの一部を実行`します。

---

<!-- .slide: id="fields-workaround" -->

### `fields` の話に戻ります

---

### fields.pm にも[弱み](#/fields-weakpoints)があると言いました

### ←それへの対策、緩和策です。

---

### Q. my 型名 $var 長いの辛い…

```perl
sub foo {
  (my MyProject::SomeModule::SomeClass $animal) = @_;
}
```

← `TYPE名` の所で constant sub を呼べるので、

```perl
sub Cat () { 'MyProject::SomeModule::SomeClass' }

my Cat $animal;
```

別名(alias)を定義すれば短く出来る

---

### Q. 別名もう一つ考えるのメンドイ…

← いっそ `MY` でどうすか？

```perl
sub MY () {__PACKAGE__}

sub age {
  (my MY $self) = @_;
  ...
}
```

---

### Q. 内部アクセスは邪道だ…

←使い方に制限を入れればどうか。

* メソッド定義中の、  
`$self->{field}` へのアクセスだけに制限

* クラスのユーザー(クライアント・コード)側では、  
従来通りアクセサー `$self->field()` を使う。

---

### Q. Accessor 欲しい

#### ←拙作: `MOP4Import::Base::Configure` をどうぞ

* `MOP4Import::Declare` に同梱
* fields + base + getter 生成 + new + setter hook


___

### ちなみに
### fields + mk_accessors な Exporter も、
### ただ作る `だけなら` 簡単です。


___

### `Exporter` とは

* 変数や関数を Export (輸出) してくれるモジュール。

* `use Foo (引数1, 2, ...);` のように使う

* これが
```perl
  BEGIN {
    require Foo;
    import Foo (引数1, 2, ...)
  }
```
として実行される

* Exporter になるモジュールには `import()` (輸入) メソッドを定義しておく

___

### %FIELDS を定義する Exporter の `例`

```perl
package Class::Accessor::Fields; # XXX: Fake module
use strict; use warnings;
sub import {
  my ($pack, @fields) = @_;
  my ($callpack) = caller;
  my $fields = fields_hash($callpack); # %{${callpack}::FIELDS}
  foreach my $f (@fields) {
     $fields->{$f} = 1;  # ←何でも良い
     next if $f =~ /^_/; # ←例えば _name はアクセサを作らない
     my $name = $f;
     *{globref($callpack, $name)} = sub {shift->{$name}};
     *{globref($callpack, "set_".$name)} = sub {shift->{$name} = shift};
  }
}
```

___

`globref()`, `fields_hash()` の定義の例

```perl
sub globref {
  my $pack_or_obj = shift;
  my $pack = ref $pack_or_obj || $pack_or_obj;
  my $symname = join("::", $pack, @_);
  no strict 'refs';
  \*{$symname};
}

sub fields_hash {
  my $sym = globref($_[0], 'FIELDS');
  # XXX: return \%{*$sym}; # If we use this, we get "used only once" warning.
  unless (*{$sym}{HASH}) {
    *$sym = {};
  }
  *{$sym}{HASH};
}
1;
```


___


#### `Class::Accessor::Fields`(仮)の使用例

```perl
package Backend;
use strict;
use warnings;

use Class::Accessor::Fields qw/_DBH dbi db_user db_pass/;
use DBI;

sub DBH {
  (my MY $self) = @_;

  $self->{_DBH} //= do {
    DBI->connect($self->{dbi}
		 , $self->{db_user}, $self->{db_pass}
		 , {PrintError => 0, RaiseError => 1, AutoCommit => 1});
  };
}
1;
```

___

### オレオレ import() 作るの楽しい！

↓

### 乱立！

↓

### …良いとこ取りが、出来ない！

___


#### 良いとこ取りが、出来なくて不便。例：

```perl
package MyExporter { use base 'Class::Accessor::Fields'; ... }
```

すると…

```perl
use MyExporter qw/$CONFIG/;  # 変数の import もしたいな←出来ない
```

```perl
use MyExporter; # Mojo みたいに use strict; use warnings も兼ねたいな←出来ない
```

#### ← 先の `Class::Accessor::Fields` では出来ない。

import を丸々、定義し直すしか無い。

___

### →そこで拙作: [`MOP4Import::Declare`](https://github.com/hkoba/perl-mop4import-declare)

* **M**eta **O**bject **P**rotocol for **I**mport
* つまみ食いしやすい import を定義するための、土台

___


* import の引数を、(プラグマと呼ぶ)パターンに応じて
`declare_...` で始まるメソッド呼び出し(＝プロトコル)
へと変換、dispatch する枠組み
    ```perl
    use MOP4Import::Declare  プラグマ1, プラグマ2, ...;
    ```
* 継承してメソッドを増やすだけで、
新しいプラグマの使える Exporter を作れる

___


```perl
package MyBaseObject;
use MOP4Import::Declare
   -as_base,
   [fields => qw/db_user db_pass/];
```

↓大体、以下と同じ

```perl
package MyBaseObject;
BEGIN {
  MOP4Import::Declare->declare_as_base(+{}, __PACKAGE__);
  MOP4Import::Declare->declare_fields(+{}, __PACKAGE__, qw/db_user db_pass/);
}
```

___

### 定義済みプラグマの例

* `-strict`
  * `use strict` 相当
* `-as_base`
  * `use parent` + `use base` 相当
  * `MY()` も自動生成
* `[fields => name1, name2, ...]`
  * `fields.pm` と同等
  * getter も自動生成


___

### 同梱: `MOP4Import::Base::Configure`

基底オブジェクトとして使えるようにしたもの。

* `MOP4Import::Declare` ＋ `new` , `configure()`

___

### 同梱: `MOP4Import::Base::CLI`

コマンド行アプリを作る時の基底オブジェクト向け

* `MOP4Import::Base::Configure` ＋ command line
* fields が option に
* メソッドがサブコマンドに

---

### Q. 内部クラスを沢山書くのは面倒

#### ←拙作: `MOP4Import::Types` をどうぞ

___

* 複数の内部クラスを `%FIELDS` 付きで一括定義  
(細かいクラス定義ファイルを沢山作りたくない時に便利)
  ```perl
  use MOP4Import::Types
    型名1 => [declareのプラグマ1, プラグマ2, ...],
    型名2 => [declareのプラグマ1, プラグマ2, ...];
  ```
* 特に生 HASH 相手の時に便利

___

### 例: 型を一括定義

```perl
package MyApp;
use MOP4Import::Types
  (Artist => [[fields => qw/artistid name/]]
   , CD   => [[fields => qw/cdid artistid title year/]]);

sub print_artist_cds {
  (my $self, my Artist $artist) = @_;
  my @cds = $self->DB->select(CD => {artistid => $artist->{artistid}});
  foreach my CD $cd (@cds) {
    print tsv($cd->{title}, $cd->{year}), "\n";
  }
}
```

* `MyApp::Artist`, `MyApp::CD` が, fields 付きで定義される
* `sub Artist () {'MyApp::Artist'}` 等も定義される。

[見比べてみましょー](#/annoying-inner-classes)

---

### まとめ

* `%FIELDS` はいいぞ！
* まめに `perl -wc` するともっといいぞ！
* `import` で型を一括定義すると、更にいいぞ！
