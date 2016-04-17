## kichijoji.pm #7

#### Perl の `use strict` をもっと活かすための
### `%FIELDS`, `perl -wc`, `import` の使い方

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
Twitter **@hkoba**  
Github: hkoba

---

## スライド URL:

http://hkoba.github.io/ → `kichijojipm` → `#7`

http://hkoba.github.io/slides/kichijojipm7/slide_ja.html

---

## 自己紹介

* `@hkoba` (in CPAN, GitHub, Twitter)
* プログラマー(フリーランス)
* 主に Perl, Tcl/Tk, Zsh  <span style="font-size: small;">(←老害？)</span>
* 代表作: `YATT::Lite`, `App::perlminlint`, `MOP4Import::Declare`


---

## 今日お伝えしたい3つのこと

#### それは…

__

# `%FIELDS` 便利!
### (`use fields` でもいい)

__

# `Save時にperl -wc` <!-- .element: style="font-size: 80%;" -->
# 安心！

__

# `use (import) で`  <!-- .element: style="font-size: 60%;" -->
# `クラスを生成`  <!-- .element: style="font-size: 60%;" -->
## すると、捗る！


#### の３つです。

---

## `use fields` (fields.pm) とは <!-- .element: style="font-size: 80%" -->

* Perl 5.5 で導入
* クラスのインスタンス変数(field)を宣言する仕組み
* 実体はパッケージ変数 `%FIELDS`

```perl
package Cat {

  use fields qw/name birth_year/;  # 名前、生まれ年

  # (ほぼ) 等価なコード
  BEGIN {our %FIELDS = (name => 1, birth_year => 2)}
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

### `%FIELDS` はコンパイル時のみ
### => 生HASHにも使える

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
            , ["Unsupported method", "psgi.version="
               , join(" ", $env->{'psgi.version'})]]; # Checked too!
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

### fields.pm だけでは Accessor が無い！

```perl
use fields qw/name birth_year/;

__PACKAGE__->mk_accessors(qw/name birth_year/); # DRY!
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

### どんな時、 `perl -wc` してますか？

1. 全然 (又は、知らなかった)
2. 気が向いた時
3. **syntastic(vim)** や **flycheck(emacs)** でエディタに統合
4. その他


---

## `perl -wc` の面倒な点

`-I....` ライブラリ・パスの設定が必要  
(use がコケる)

```sh
% perl -wc demos/2/foo.pl
Can't locate Foo.pm in @INC (you may need to install the Foo module) (@INC contains: ...
```

___

## モジュールの場合：

`perl -MMod -e0` の方が、
多くのエラーを見つけてくれる(ex. `require` の TYPO, `import()` のエラー...)

```sh
% perl -wc demos/2/lib/Foo.pm
demos/2/lib/Foo.pm syntax OK

% perl -Idemos/2/lib -MFoo -e0
Can't locate Barr.pm in @INC (...
```

---

### そこで `App::perlminlint`

https://github.com/hkoba/app-perlminlint

`perl` の代わりに `perlminlint` を呼ぶだけ

```sh
perlminlint  YOUR_SCRIPT
```

___

### 主なオプションは互換

`-wc` も渡せます。(既存のツールとの互換性のため)

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

### perlminlint をエディタから呼ぶには

#### Emacs の flycheck の場合

App::perlminlint に設定例
([flycheck-perlminlint](https://github.com/hkoba/app-perlminlint/tree/master/flycheck-perlminlint))が同梱

```elisp
(flycheck-set-checker-properties
      'perl
      '((flycheck-command "perlminlint" source-original)))
```


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

### fields の話に戻ります

### fields.pm にも[弱み](#/fields-weakpoints)があると言いました

---

### my 型名 $var を楽にするには

```perl
sub foo {
  (my MyProject::SomeModule::SomeClass $animal) = @_;
}
```

実はこの `TYPE名` の所で constant sub を呼べるので

```perl
sub Cat () { 'MyProject::SomeModule::SomeClass' }

my Cat $animal;
```

とか出来ます

---

### 名前考えるのメンドイ…

いっそ `MY` でどうすか？

```perl
sub MY () {__PACKAGE__}

sub age {
  (my MY $self) = @_;
  ...
}
```

---

### Q. 内部アクセスは邪道

* →クラス定義 `*.pm` の中でだけ、  
`my MY $var` と `$var->{field}` を許す

* クラスのユーザー側では、従来通り、アクセサーを使う。

___

### Q. Accessor 欲しい

### → `fields + mk_accessors` なモジュールを作ればいい！

---

### `fields + mk_accessors`?

### →オレオレ import() の世界へようこそ！

```perl
package Class::Accessor::Fields; # XXX: Fake module
use strict; use warnings;
sub import {
  my ($pack, @fields) = @_;
  my ($callpack) = caller;
  my $fields = fields_hash($callpack); # %{${callpack}::FIELDS}
  foreach my $f (@fields) {
     $fields->{$f} = 1; # ←何でも良い
     my $name = $f;
     *{globref($callpack, $name)} = sub {shift->{$name}};
     *{globref($callpack, "set_".$name)} = sub {shift->{$name} = shift};
  }
}
1;
```

___


```sh
% perl -Idemos/3/lib -MClass::Accessor::Fields=foo,bar,baz -Mstrict -le '
  sub MY () {__PACKAGE__};
  sub foo {
    my MY $foo = shift;
    $foo->{fo} + $foo->{bar}
  }
'
No such class field "fo" in variable $foo of type main at -e line 1.
```
