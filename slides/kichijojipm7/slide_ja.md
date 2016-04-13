#### Perl の `use strict` をもっと活かすための
### `%FIELDS`, `perl -wc`, `import` の使い方

## kichijoji.pm #7

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
Twitter **@hkoba**  
Github: hkoba

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
# `型を生成`  <!-- .element: style="font-size: 60%;" -->
## すると、捗る！


#### の３つです。

---

## `use fields` (fields.pm) とは <!-- .element: style="font-size: 80%" -->

* Perl 5.5 で導入
* クラスのインスタンス変数(field)を宣言する仕組み
```perl
package Cat;
use fields qw/name birth_year/;  # 名前、生まれ年
```
* 変数の型宣言と併用
```perl
my Cat $cat;
```
* コンパイル時に、静的に field の TYPO(タイポ、つづり間違い)を検知してエラーに
```perl
$cat->{namae} = 'foo';   # コンパイル時にエラー！
say $cat->{birth_yearr}; # コンパイル時にエラー！
```


___

### `use fields` の例: クラス定義

```perl
package Cat {
 
   use fields qw/name birth_year/; # field declaration
 
   sub new {
      my Cat $self = fields::new(shift); #  my TYPE $sport.
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

### あなたを守る fields.pm、
## 何故使われなかったのか…

__

### fields.pm は Accessor を作ってくれない！

```perl
use fields qw/name birth_year/;
__PACKAGE__->mk_accessors(qw/name birth_year/); # DRY!
```

### 型名つけるのが面倒！

```perl
my MyModuleX $foo;
my MyModuleY $bar;
```

### 型名が長くなるともっと辛い！

```perl
my MyProject::SomeModule::SomeClass $obj;
```

___

### そもそも `perl -wc` を滅多に使わない?!

---

## I will talk about:

* `perl -wc` and `use strict`
   * So, **When** to _perl -wc_?  
   (いつ _perl -wc_ を呼ぶべきか)
* `use fields` and `%FIELDS`

See [MOP4Import-Declare/whyfields](https://metacpan.org/pod/distribution/MOP4Import-Declare/whyfields.pod) for this talk.

---

# Demo 1



---

## Question!

When do you run `perl -wc` for your program?  
(どんな時、 `perl -wc` してますか？)

1. Never (全然)
2. Occationary (気が向いた時)
2. Every releasing (リリース時)
3. Every testing (テスト時)
4. <span class="fragment highlight-blue">Every editing (編集する度)</span>


---


## Why we love `use strict` ?

* Finds **TYPOs** of variable names.
* **Before** it runs.

---

# "Before"

Really?

