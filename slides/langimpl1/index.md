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
* 今の仕事では主に Perl, Tcl, Zsh, Emacs Lisp
* <small>他、好きな言語： C++, OCaml, Lisp, Smalltalk, Prolog, FORTH…(雑食)</small>
* <small>TypeScript 勉強中</small>

---

### あらすじ

1. yatt とは
2. どうして自作？何のために？
3. yatt について、もう少しkwsk
3. 実装上の工夫

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

### 2. どうして自作？何のために？



---

## 3. yatt について、もう少しkwsk


---

### yatt が使う名前空間は設定で変更可能

Ex. **`yatt:`** の代わりに **`conpass:`**

```html
<connpass:event id="104863">
  言語処理系勉強会
</conpass:event>
```

指定した名前空間の要素だけを触り、それ以外は素通し

---

### widget(画面部品) の定義

```html
<!yatt:widget 名前 引数...>
定義の本体
```

例

```html
<!yatt:widget layout title>
<title>&yatt:title;</title>
<body>
  <div id="content">
    <yatt:body/>
  </div>
</body>
```

---

### entity reference式(埋め込み要素)

例

```html
&yatt:title;                <!-- 変数参照 -->

&yatt:query_string();       <!-- ヘルパー関数の呼び出し -->

&yatt:max(:x,:min(:y,:z));  <!-- 引数に関数呼び出し -->

&yatt:CON:param();          <!-- Object のメソッド呼び出し -->

&yatt:query((select * from t)); <!-- 引数にスペースを含める時 -->

```

---

### widget 呼び出し

```html
<yatt:layout title="Hello">
  <h2>world!</h2>
</yatt:layout>
```

引数は attribute 以外に **:yatt:** 始まりの要素としても書ける<br>
→引数の中にタグを書いても、HTML 的に汚くならない

```html
<yatt:layout >
  <:yatt:title>
    <b>H</b>ello
  </:yatt:title>

  <h2>world!</h2>
</yatt:layout>
```

<small>(common-lisp の **:keyword** 引数からの着想)</small>

---

### 2. なぜこうした？
### 設計意図は？
### 背景は？

---

<small>そもそも</small>

## なぜテンプレートエンジンを自作？



---

### XML/HTML に似せる(極力)

HTML モードの有るエディタなら、そこそこ使える。

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

(再掲)

---

### typo を早期に、静的に検出する(極力)

---

### 変数に(escapeの)型がある

---

### 特徴1. XML/HTML 用の開発環境を流用できる

普通に html/xml として認識させるだけでも、それなりに読める。


