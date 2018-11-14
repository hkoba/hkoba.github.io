### こんなテンプレートエンジンは
### 言語処理系に入りますか？
#### テンプレートエンジン yatt の話

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba**

#### 言語処理系勉強会 Vol.1 (2018-11-17)


---

### 自己紹介: hkoba

プログラミング言語ミーハー、自宅研究

* 今の仕事では主に Perl, Tcl, Zsh, Emacs Lisp
* 他 C++, OCaml, FSharp, APL/J, Smalltalk, Prolog, FORTH 色々好き
* TypeScript 勉強中

- - - - -

#### 今日のスライドは↓こちら

 [hkoba.github.io](https://hkoba.github.io/)
→ [`言語処理系勉強会 Vol.1`](https://hkoba.github.io/slides/langimpl1/)

---

### 発表内容

1. 自作テンプレートエンジン yatt の概要
2. 実装上の工夫
3. 

---

## [yatt](https://yl-podview.herokuapp.com/mod/YATT::Lite::docs::yatt_manual)  (Yet Another Template Toolkit)とは

XML 風の独自構文 ([LRXML](https://yl-podview.herokuapp.com/mod/YATT::Lite::LRXML::Syntax)) で記述されたテンプレートを<br>
別の言語 (主にperl) の手続き群へ変換する、<br>
オンデマンド・トランスパイラー

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

yatt で書いたテンプレートの例


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
