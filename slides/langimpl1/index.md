### こんなテンプレートエンジンは
### 言語処理系に入りますか？
#### 自作テンプレートエンジン yatt の話

##### [言語処理系勉強会 Vol.1](https://connpass.com/event/104863/) (2018-11-17)

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba**

https://github.com/hkoba/yatt_lite

___

#### 今日のスライド↓

 [hkoba.github.io](https://hkoba.github.io/)
→ [`言語処理系勉強会 Vol.1`](https://hkoba.github.io/slides/langimpl1/)

---

### 自己紹介: hkoba

* <small>(名ばかりの)</small>フリーランス・プログラマ
* プログラミング言語ミーハー
* 主な仕事言語： Perl, Tcl, Zsh, Emacs Lisp
* <small>他、好きな言語： C++, OCaml, Lisp, Smalltalk, Prolog, FORTH…(雑食)</small>
* <small>TypeScript 勉強中</small>

---

### あらすじ

1. yatt とは
2. 開発動機・背景・要求
3. yatt について、もう少し詳しく
4. 実装上の工夫

---

## 1. yatt とは

---

## [yatt](https://yl-podview.herokuapp.com/mod/YATT::Lite::docs::yatt_manual)  <small>(Yet Another Template Toolkit)</small>とは

* XML 風の独自構文
<small>([LRXML](https://github.com/hkoba/yatt_lite/blob/dev/Lite/LRXML/Syntax.pod))で記述されたテンプレートを</small>
* <small>(主にWebからのリクエストに応じて)</small>オンデマンドで、
* ターゲット言語 (主にperl) の手続き群へ変換し実行する、

**トランスパイラー** 兼、実行環境

___

### yatt で書いたテンプレートの例

```html
<yatt:layout title="Hello">
  <h2>world!</h2>
</yatt:layout>

<!yatt:widget layout title>
<title>&yatt:title;</title>
<body>
  <div id="content">
    <yatt:body/>
  </div>
</body>
```

___

```perl
#line 1 "/home/hkoba/db/work/hkoba.github.io/slides/langimpl1/ex/ex1.yatt"
package MyYATT::INST1::EntNS::ex1; use strict; use warnings; use 5.010; use mro 'c3'; our @ISA = qw(MyYATT::INST1::EntNS); use utf8; sub filename {__FILE__}; sub render_ { my ($this, $CON) = splice @_, 0, 2; my $body = $_[0];  $this->render_layout($CON, (undef, q|Hello|, sub {
 print $CON (q|  <h2>world!</h2>|);}
)[1, 2]); print $CON ("\n");}

sub render_layout { my ($this, $CON) = splice @_, 0, 2; my $title = $_[0]; my $body = $_[1];
 print $CON (q|<title>|, YATT::Lite::Util::escape($title), q|</title>|, "\n");
 print $CON (q|<body>|, "\n");
 print $CON (q|  <div id="content">|, "\n");
  $body && $body->();
 print $CON (q|  </div>
</body>|); print $CON ("\n");}
```

変換結果 (perl)

___

```html
<title>Hello</title>
<body>
  <div id="content">
  <h2>world!</h2>  </div>
</body>
```

実行時の出力 (html)


___

#### yatt のコンセプト

### <small>そこそこ</small>キレイな php

<small>(怒られそう)</small>

---

* 実装: Pure perl
* 開発: hkoba 一人
* 規模: 8,700行ほど<small>(最新バージョン yatt_lite)</small>
* 実績: hkoba のお客様が10年<small>(※)</small>ほど使用中
<small>(※旧バージョン中心)</small>

---

## 2. 開発動機・背景・要求

---

## 動機

仕事の手離れを良くするため

---

### 背景：お客様([![SSRI](ssri_logo.gif)さん](https://www.ssri.com/))の事業

* 医療従事者向け、アドホック・アンケート

![](img/ssri_workflow.svg)

ただし、件数が多い

---

### 本数が多いのに、全部違う

* 500本/年<small>以上</small>
* フルカスタム<small>(基本、 **全部違う** )</small>
  * <small>平均40ページ程</small>
  * <small>分岐・絞り込みの条件も複雑</small>

---

### 期間が短い

* 開発: 一週間
* 運用: 一週間
* そして捨てる

---

## 全部に

## 密に関わってたら

## 人生が食い尽くされてしまう

---

### 動機：顧客が自力で案件を回せる度合いを最大化したい

自立のために、 **顧客に渡す武器** 、それが yatt

___

### 隠れた動機：

#### 言語好きとしての

### 魂を殺さないため

---

## 要求

---

![](img/ssri_workflow.svg)

実装とオペレーションは、 **プログラミング未経験** で採用して
社内で教育した人たち

---

### CS未履修・実務経験なしでも

### 安全に仕事できる言語が

必要だった

---

頭の良い人に合わせた言語ではなく

不慣れな人でも日々の糧を得られる武器になること

___

#### 余談：だから、言語だけじゃ駄目

<video controls>
<source src="../hachiojipm72/img/tcltk_emacs.webm" type="video/webm">
<source src="../hachiojipm72/img/tcltk_emacs.ogv" type="video/ogg">
再生できるかな？
</video>

---

### 設計目標

* <small>(未経験者でも見慣れてる)</small>HTML との親和性
* 静的な typo の検出

---

## 3. yatt について、もう少しkwsk

---

### <small>(yattの)</small> widget とは

* 引数として <small>(自身の名前空間 this と)</small> 出力ストリーム CON、他を受け取り
* そのストリームに内容を書き込む関数

- - - - -

#### 雑に言うと、コンテンツのコンストラクタ?

---

### widget(画面部品) の定義

<small>(ファイル名=部品名、の場合)</small>

```html
<!yatt:args 引数名 [= "型 フラグ デフォルト値"] ...>
定義の本体
```

例([mytest1.yatt](ex/mytest1.yatt))

```html
<!yatt:args foo bar="html?bar's default" class>
<div class="&yatt:class;">
  <h2>&yatt:foo;</h2>
  <h3>&yatt:bar;</h3>
  <yatt:body/>
</div>
```

___


```perl
#line 1 "/home/hkoba/db/work/hkoba.github.io/slides/langimpl1/ex/mytest1.yatt"
package MyYATT::INST1::EntNS::mytest1; ...; our @ISA = qw(MyYATT::INST1::EntNS); ...;
sub render_ {
  my ($this, $CON) = splice @_, 0, 2;
  my $foo = $_[0];
  my $html_bar = (defined $_[1] && $_[1] ne "" ? $_[1] : q|bar's default|);
  my $class = $_[2];
  my $body = $_[3];
  print $CON (q|<div class="|, YATT::Lite::Util::escape($class), q|">|, "\n");
  print $CON (q|  <h2>|, YATT::Lite::Util::escape($foo), q|</h2>|, "\n");
  print $CON (q|  <h3>|, $html_bar, q|</h3>|, "\n");
  $body && $body->();
  print $CON (q|</div>|, "\n");
}
```

変換結果(手で整形。 ... は省略)

---

### タグ＝widget 呼び出し

```html
<yatt:部品名 引数名="値" ... />

<yatt:部品名 引数名="値" ... > body 引数に渡す値 </yatt:部品名>
```

例([ex3.yatt](ex/ex3.yatt))

```html
<yatt:mytest1 foo="hoge" class="content">
  <p>Hello world</p>
</yatt:mytest1>
```

___


```perl
#line 1 "/home/hkoba/db/work/hkoba.github.io/slides/langimpl1/ex/ex3.yatt"
package MyYATT::INST1::EntNS::ex3; ...; our @ISA = qw(MyYATT::INST1::EntNS); ...;
sub render_ {
  my ($this, $CON) = splice @_, 0, 2;
  my $body = $_[0]; # XXX: not used
  MyYATT::INST1::EntNS::mytest1->render_(
    $CON,
    (undef, q|hoge|, q|content|, sub {
       print $CON (q|  <p>Hello world</p>|);
     }
    )[1, 0, 2, 3]
  );
  print $CON ("\n");
}
```

変換結果(手で整形。 ... は省略)

---

### 型<small>(ただし、引数の解釈と出力 escaping のための、最低限)</small>

<!-- .slide: class="small" -->

|型名|解説|
|---|---|
|text|デフォルト。 escape される|
|html|escape 済みとして、そのまま print される|
|attr|html の attribute=value を簡潔に書く仕組み|
|value|ホスト言語の生の式を書ける|
|code|クロージャ|
|delegate|継承の代わり|

---

### entity reference式(埋め込み要素)

例

```html
&yatt:title;                    -- 変数参照

&yatt:query_string();           -- ヘルパー関数の呼び出し

&yatt:max(:x,:min(:y,:z));      -- 引数に関数呼び出し

&yatt:CON:param();              -- Object のメソッド呼び出し

&yatt:query((select * from t)); -- 引数にスペースを含める時

```

---

## 4. 実装上の工夫

---

### それなりにチャレンジ

* FastCGI <small>(常駐プロセス)</small> だけでなく普通の CGI (リクエスト毎に起動)でも
十分高速であること
* エラーを可能な限り静的に検出できること


---

### parse と typo 検出を軽くする
### (仕様上の)工夫

* 指定した名前空間(デフォルトでは **`yatt:`**) の要素だけを触り、それ以外は素通し
* 宣言( **`<!yatt:...>`**) を構文的に分けたので、そこだけ先に parse 出来る。
  * <small>呼ばれたファイル内の widget 群の仕様が先に分かるので、フルのトランスパイルが走る前に、呼ぶ側の typo が判定できる</small>

---

#### 宣言かコメント<small>(の先頭)</small>にマッチする
#### 正規表現を作っておく

```perl
package YATT::Lite::LRXML;
...
sub after_new {
  my MY $self = shift;
  ...
  $self->{cf_namespace} ||= [qw(yatt perl)];
  my $nspat = qr!@{[join "|", $self->namespace]}!;
  $self->{re_decl} ||= qr{<!(?:(?<declname>$nspat(?::\w++)+)
			  |(?:--\#(?<comment>$nspat(?::\w++)*)))\b}xs;
  ...
}
```


---

入力を正規表現で削るループでパーサーを表現

```perl
package YATT::Lite::LRXML;
...
sub parse_decl {
  (my MY $self, my Template $tmpl, my $str, my @config) = @_;
  ...
  ($self->{startpos}, $self->{curpos}, my $total) = (0, 0, length $str);

  while ($str =~ s{^(.*?)($$self{re_decl})}{}s) {
    ...
```

<small>(yatt の宣言には入れ子が無いのでループで十分)</small>


---

後は構造に詰めるだけ

```perl
  ...
  while ($str =~ s{^(.*?)($$self{re_decl})}{}s) {
    $self->add_text($part, $1) if length $1;
    $self->{curpos} = $total - length $str;
  
    if (my $comment_ns = $+{comment}) {
      ...
      push @{$part->{toks}}, [TYPE_COMMENT, $self->posinfo($str)
			      , $self->{startln}
			      , $comment_ns, $nlines, $1];
      next;
    }
    my ($ns, $kind) = split /:/, $+{declname}, 2;
    ...
  }
}
```

___

#### 余談： Perl にも型宣言あるんですよ知ってましたか？

```perl
use fields qw/re_decl
	      template
	      startln endln
	      startpos curpos .../;
...
sub parse_decl {
  (my MY $self, my Template $tmpl, my $str, my @config) = @_;
  
  $self->{template} = $tmpl;
  $tmpl->reset if $tmpl->{product};
```

<small>
field (インスタンス変数) 名の typo をコンパイル時に検出できます。

これ抜きで言語処理系ぽいものを作るとか、無理だし…

(20年前からある機能ですが、使う人少ないですね…)
</small>

