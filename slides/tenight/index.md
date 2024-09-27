# 仕事の手離れ
### を良くする手段としての、
# 静的検査
### のあるテンプレートエンジン

<img src="myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** 

________

### 自己紹介: @**hkoba** <img src="myfistrect.jpg" style="width: 64px; height: 64px">

* 小林弘明
* 個人事業主<small>(2003〜)</small>
* <a href="http://www.ssri.com/recruit/" alt="ssri.com"><img src="ssri_logo.svg"alt=SSRI> **SSRI.com** </a>さんの Web のお仕事
  * Perl, <small>Tcl/Tk, Zsh, EmacsLisp</small>
* <small>テンプレートエンジン</small>**YATT::Lite** 作ってます
  * [github.com/hkoba/yatt_lite](https://github.com/hkoba/yatt_lite)

________


* Perl 関連
  * 〜1996. Perl/Tk 日本語化 <small>(学生時代)</small>
  * 1998\. [Perl Conference Japan speaker](http://www.oreilly.co.jp/pcjp98/session.htm#W2)
  * YAPC::Asia 2000. [YATT -- Yet Another Template Toolkit, Designed for WebDesigners](http://yapcasia.org/2010/talks/63D5293C-BC8C-11DF-8791-B9FC0F276C45)
<hr>
* 他の仕事
  * 1997-2000
    * **MMO** サーバー用 俺々スクリプトエンジン
       * <small>pthreadで NuMA対応, ちょっと Erlang っぽいやつ</small>
  * 2001-2002
    * **組込Linux** 移植, ドライバー受託開発

--------

### 話の概要

1. <small>hkobaの言う</small>**仕事の手離れ**<small>とは?</small>
2. テンプレートエンジン **yatt** の紹介
3. なぜ、この仕様にしたか<small>(=**昔話**. 開発動機)</small>
4. FAQ <small>(時間が余れば)</small>

--------

`(hkobaの言う)`
## **1.** 仕事の手離れ<small>とは?</small>

#### <small>仮に</small>プログラマーを２層に分けるとして:

* インフラ層
* ビジネス層(プロダクト・受注案件層)

<small>(どちらが偉いとかじゃないです。念の為)</small>

________

### インフラ層PG**にとっての**「手離れ」

* リリース後に
* 案件毎の事情で
* 追加作業が
   * 発生しない, or
   * 減っていく<small>こと</small>

--------

## (お断り)
### **ウチの** <small>今の精一杯の</small>
### **現実解**<small>の話です</small>
________


## 皆さんにとって
## 良い解か… **⇒？**

________


### Ex. **誰が** template を **書くか** で
### 最適解は変化
________

### 誰がテンプレートを書くか

* **自分**が(=PGが)書く
* **デザイナーさん**に書いてもらう
* **お客様**が書く

________

### <small>ウチは</small>**お客様** ![SSRI](ssri_logo.gif) 
### <small>(の雇ったスタッフさん)</small>が
### template<small>(=ビジネス層)</small> を書く

<hr>

#### <img src="myfistrect.jpg" style="width: 64px; height: 64px"> hkoba は
#### インフラ層作りと
#### スタッフさんの訓練

--------

## **2.** yatt とは

* **Y**et **A**nother **T**emplate **T**oolkit
  * Pure Perl

<small>↓テンプレートの例:</small>
```xml
<!yatt:args TITLE CLASS body=code>
<div class="&yatt:CLASS;">
<h2>&yatt:TITLE;</h2>
&yatt:body();
</div>
```
<small>(TITLE, CLASS, body が引数。普段は lower case)</small>
________

### **注**. yatt は **２つ** あります！

on CPAN

* YATT (2006-2010)
* **YATT::Lite** (2010-)

________

## **<small>(古い)</small>** YATT <small>(2006-2010)</small>

* ほぼ全案件(年間500本以上)で稼働
* 実装, APIが **不満**
* 無視して!

________

## **YATT::Lite** <small>(2010-)</small>

* 改訂版
  * 構文互換
  * API を整理
  * 実装も大分マシに
* **こちらを** 使って下さい
* [github.com/hkoba/yatt_lite](https://github.com/hkoba/yatt_lite)
  * ご意見お待ちしてます！マジで！

--------

### インストール

```sh
cpanm YATT::Lite
```

#### スグに使えるインストーラ

```sh
curl https://raw.github.com/hkoba/yatt_lite/dev/scripts/skels/min/install.sh | 
bash
```

#### (手でやるのも簡単)

* `git clone`
* (cpanm --installdeps .)
* `.psgi` をコピー
* `mkdir html`
* `plackup`!

________

## スグに plackup 出来る psgi

```sh
$ git clone git://github.com/hkoba/yatt_lite.git lib/YATT
$ (cd lib/YATT && cpanm --installdeps .)
$ cp lib/YATT/samples/minimum.psgi app.psgi
$ mkdir html
$ echo hello > html/index.yatt
$ plackup
```

#### `samples/minimum.psgi` の中身

```perl
use strict;
use FindBin;
use lib "$FindBin::Bin/lib";
use YATT::Lite::WebMVC0::SiteApp -as_base;
{
  my $site = __PACKAGE__->new(app_root => $FindBin::Bin,
                              doc_root => "$FindBin::Bin/html");
  $site->to_app;
}
```

--------

### オンライン・マニュアル:
## ylpodview

#### http://ylpodview-hkoba.dotcloud.com/

________

### マニュアル

<dl>
<dt>テンプレート(**yatt:widget**) の構文
<dd>
[yatt_manual](http://ylpodview-hkoba.dotcloud.com/mod/YATT::Lite::docs::yatt_manual) -- yatt 構文マニュアル
<dd><small>(未完成ですが＞＜)</small>
<dt>開発チュートリアル
<dd>
[yatt_guides_for_pm](http://ylpodview-hkoba.dotcloud.com/mod/YATT::Lite::docs::yatt_guides_for_pm) - Perl Monger のための yatt ガイド
<dd><small>(全然書けてません＞＜)</small>
</dl>

--------

### yatt は HTML に似せました(<small>意図的</small>)


##### **&lt;タグ&gt;** を *"widget 呼び出し"* に

```xml
<yatt:部品名 引数... />
```

```xml
<yatt:部品名 引数...>
 ..
</yatt:部品名>
```

________

##### **&amp;実体参照;**  を *"変数や関数の埋め込み"* に

```xml

&yatt:変数名;

&yatt:関数名(引数,...);
```
________

##### **&lt;!doctype&gt;** を *"widgetの宣言"* 兼 *"multipartの区切り"* に

```xml

<!yatt:widget FOO 仮引数...>
  ...FOOの定義本体...


<!yatt:widget BAR 仮引数...>
  ...BARの定義本体...
```

--------

### 一ファイルに複数 widget 定義可能

```xml
<!yatt:args 仮引数...>
  ...デフォルト widget の定義...

<!yatt:widget FOO 仮引数...>
  <h2>FOOの定義本体</h2>

<!yatt:widget BAR 仮引数...>
  <h2>BARの定義本体<h2>
```

### **`<yatt:FILE:NAME>`** で呼べる

```xml
<yatt:layout:FOO>...</yatt:layout:FOO>
<yatt:layout:BAR>...</yatt:layout:BAR>
```

________

### **`<yatt:DIR:FILE>`** で<small>デフォルト widget呼び出し</small>

```xml
<yatt:mydir:layout>...
```

<hr>

### **`<yatt:DIR:FILE:NAME>`** で<small>サブwidget</small>

```xml
<yatt:mydir:layout:FOO>...
```

<hr>

### DIR も FILE も
### widget の **コンテナ** <small>として抽象化</small>

--------

### 書いてみる

Ex. こんな↓定形レイアウトを **widget化** するには？

```xml
<div class="●">
<h2>△△</h2>
■■■
</div>
```

* 穴埋め付きで
   * `●`
   * `△△`
   * `■■■`
* **`<yatt:layout>`** って呼びたい

______

#### **layout.yatt** という名前で保存

```xml
<!yatt:args TITLE CLASS body=code>
<div class="&yatt:CLASS;">
<h2>&yatt:TITLE;</h2>
&yatt:body();
</div>
```

* <small>拡張子を除いた</small>ファイル名＝widget 名

________

#### **layout.yatt** を呼び出す側 (**index.yatt**)

```xml
<yatt:layout TITLE="△△" CLASS="●">
■■■
</yatt:layout>
```

#### ⇒ 出力 HTML

```xml
<div class="●">
<h2>△△</h2>
■■■
</div>
```

________

ex. TITLE を `Hello world!` に変えてみる

```xml
<yatt:layout TITLE="Hello world!" CLASS="content">
It's show time!
</yatt:layout>
```

#### ⇒ 出力 HTML

```xml
<div class="content">
<h2>Hello world!</h2>
It's show time!
</div>
```


________

### 動的に変換され Perl のコードへ

```perl
package MyApp::INST1::EntNS::layout;
use strict;
use warnings;
use 5.010;
our @ISA = qw(MyApp::INST1::EntNS);
#line 1 "/home/hkoba/db/monthly/201409/tenight/app1/html/layout.yatt"
sub render_ {
  my ($this, $CON) = splice @_, 0, 2;
  my $TITLE = $_[0];
  my $CLASS = $_[1];
  my $body = $_[2];
  print $CON (q|<div class="|, YATT::Lite::Util::escape($CLASS), q|">|, "\n");
  print $CON (q|<h2>|, YATT::Lite::Util::escape($TITLE), q|</h2>|, "\n");
  $body && $body->(); print $CON (q|
</div>|); print $CON ("\n");}
```

(`yatt genperl html/layout.yatt` の出力)

________

#### (参考) layout を呼ぶ側の生成コード

```perl
package MyApp::INST1::EntNS::index; 
use strict; 
use warnings; 
use 5.010; 
our @ISA = qw(MyApp::INST1::EntNS); 
#line 1 "/home/hkoba/db/monthly/201409/tenight/app1/html/index.yatt"
sub render_ {
  my ($this, $CON) = splice @_, 0, 2;
  my $body = $_[0];
  MyApp::INST1::EntNS::layout->render_($CON,
     (undef, q|Hello world!|, q|content|, sub {
      print $CON (q|It's show time!|);}
)[1, 2, 3]); print $CON ("\n");}
```

(`yatt genperl html/index.yatt` の出力)

--------

## **3.** なぜ,この仕様に？ <small>(=**昔話**. 開発動機)</small>

________

### 理由
## **雇い主** <small>が HTML ネィティブ！</small>
(だった)

________

## 最初の上司<small>(1996)</small>
### **自分で HTML を書けた**

Webデザイン自分で勉強してた

ドメインも自力で取ってた

<small>(後に渡米したり起業したり)</small>
________

### 当時から <img src="myfistrect.jpg" style="width: 64px; height: 64px"> hkoba は

## **小さな部品** <small>信者</small>

単機能な部品の組み合わせ、サイコー!

________

SSI<small>モドキ</small> の仕組みを作って納品してた

```xml
<hr>
<!--#listSink *.html -->
<hr>
```

SSI 風の部品が html を作って返す

```perl
# in listSink.sub:
foreach ($sink->glob($pattern)) {
 $sink->add(<<END);
<tr align=left>
 <td><input type=checkbox name=path value="$_"></td>
 <th>$dir/$file</th>
 <td>$url</td> <!-- $name -->
</tr>
END
}
```

* <small>綺麗に部品に切り分けた</small>,つもりだった
* リリース！

________

## 「こばち〜ん」

________

## 「<small>部品の返す</small> html
## 変えてくんない？」

________

## …手離れしてない…

________

## **隅々まで template に** 
### しないと
## 手が掛かり<small>続ける</small>

________

「コメントで書くの(SSI) って、**ダサい**よね」

「タグで書けたらいいのに〜<small>(チラッ)</small>」

________

## デスヨネー

________

## 次の上司<small>(1997〜2003)</small>

### も, HTML を自分で書く人

________

今度は

部品から返す html も

テンプレートで作るようにした
________

#### html の中に perl の処理を埋め込んだ

```xml
</td>
</tr>
<!--#begin eval-->
  my ($cgi, $self) = @_;
  ...
  push @survey, qq(<tr><td>$handle</td>...);
  ...
<!--#end-->
<tr>...
```

* 納品した！

________

## 「こばち〜ん」

________

「ここのタグ、ちょっと変えたら 

### **動かなくなった** <small>(てへっ)</small>

### **直してくんない？**」

________

## …手離れしてない…

________

## **壊したらスグに** 

### 知らせるべき

## <small>**さもないと**</small>手離れしない

________

故に！次のエンジンでは

* **`perl -wc`** 的な静的検査のコマンド

を作ることを決意！

________

## 次の上司<small>(2003〜2008)</small>

### 元 **PHPer**
### **デザイナー気質**
#### デザインセンスあり

________

2005年版は大分 HTML っぽいテンプレートに.

```xml
<ssri:foreach my=value selected="p11/q12-2a-1" file=q12 except=10>
  <li>$$value[1]</li>
</ssri:foreach>
<td width="300" bgcolor="#ebf0f3" rowspan="10" >
<ul style='padding-left: 0px; list-style: none;'>
<ssri:foreach my=value selected="p11/q12-2a-1" file=q12 except=10>
  <li>$$value[1]</li>
</ssri:foreach>
```


________

「小林さ〜ん」

「ここを**まとめて、部品に**できませんかね〜？」

________

## 部品 **化** <small>(抽象化)</small>の機能が
### 無いと
## デザイナーは満足しない


(繰り返しが **ダルい** のは、デザイナーも同じ)
________

## => 後付けした

________

2005 版テンプレートでの、部品定義の例

```xml
<!--#perl simple
  my $args = shift; ...
-->
<ssri:foreach my='label' list='@list'><tr>
<?perl
   my $item = _label($PAGE, $CGI, {%$args, 'row', $label});
?>
<td>$name--$$label[0]</td>
<td>$item</td>...
```

部品名: `simple`

________

「**PHP と比べて**も、別に綺麗じゃないっすよね？」

「もっと簡単に、 HTML ぽく書けないっすかね〜」

「タグで書けると、いいんすけどね〜」

________

## ぐぬぬ…

________

<small>そして</small>何より

## 部品づくりが
## 難しすぎた！

________

* 難しいから、**部品にしない**
* 代わりに abbrev/snippet (emacs の **短縮辞書** ) に頼る
  * Write Only! <small>(後で修正が来ると死ぬ)</small>
  * 属人化!

________

### 静的検査のコマンドも
### 滅多に **呼んでくれない**

* 相変わらず、アクセスしてエラーに気づく
  * <small>(引数が hash表渡しなので、引数間違いを静的に検出出来ない問題も)</small>
________

エラー見ても

壊れまくった後だから

「どこ直せば良いのか分からないんすよね〜」

________

### **壊したらスグに** 知らせないと
### 手に負えなくなる！

________

## HTMLネィティブが
## 雇い主！

________

### タグで部品を呼ばせろ！
### 俺のタグを作らせろ！

________

### やっと出来たのが、今の yatt

```xml
<!ssri:widget simple type=! name=! value_col="value/0"
  base=[delegate:ssri:common:table] label=[delegate:ssri:common:label]
>
<ssri:base>
  <ssri:my id="&ssri:name;--&ssri:row[:value_col];"/>
  <td><input type="&ssri:type;" name="&ssri:name;" value="&ssri:row[:value_col];" id="&ssri:id;"></td>
  <td><ssri:label row id class=label_class
                         style=label_style/></td>
</ssri:base>
```

--------

## HTML に似せた利点

________

### (利点.1) HTML 用の構文着色を流用可

* github (**highlight.js**)
* emacs, vim
* bracket.io?, atom?, sublime?


________

### (利点.2) 採用、教育が<small>比較的</small>楽

* HTML の分かる人なら容易
  * <small>(採用で不利な)</small>中小企業には重要

________

### デザイナや**非**プログラマで
### 大丈夫なの？

* 手続き的側面は、隠せる
  * 宣言的な widget として教えられる
  * コピペして組み合わせるだけ
    * (間違いは **保存時に検出** するので)

________

### yatt は **typo** 検査を頑張ります

```xml
<yatt:layoout TITLEE="Hello world!" CLASS="content">
It's show time!
</yatt:layoutt>
```

* `<yatt:layoout>`
* `TITLEE=..`
* `</yatt:layoutt>`


________

## **保存時**に lint
### エラー箇所に
### 強制ジャンプ(emacs)

________

## 壊れたらスグに気づく<small>ように</small>

### でないと、すぐに諦めてしまう

________

### 他にも

* emacsclient + tcltk で IDE ぽくしたり

--------

### 参考：![SSRI](ssri_logo.gif)さんの事業

* 医療従事者向け、アンケート
* 質問内容が専門的
* 40ページ程

________

### 規模

* 年間500本以上の案件
* フルカスタム(基本、 **全部違う** )
* 7人の、アンケート・プログラマー
* hkoba がトレーナー
________

### スケジュールの感覚

* 開発: 一週間
* 運用: 一週間
* そして捨てる

________

### 一週間で捨てるコードに

* テストを書く?
  * ペイしない
* 静的検査を頑張るしか

--------

## **4.** FAQ

* 何で **yatt:** ?
* ログイン処理とかDBアクセスは？
* 何で doc_root 直下に template 置くの？
* 何でコード生成？
* `<yatt:foo>...</yatt:foo>` みたく囲む意味は？
* 引数への入れ子は？
* Mojolicious/Amon2/Dancer... から使うには？
* 1ファイルアプリを作りたいときは？
* 今さら Perl?
* 今さらサーバー側テンプレート？

--------

### **Q.** 何で **yatt:** ? <small>冗長では?</small>

________

* メタプログラミング(多段テンプレート)への備え
* parser も楽
* `(namespace => [qw/yatt perl/])` 設定可能
  * チーム固有の部品が一目で (ex. **ssri:〜**) 区別出来る

--------

### **Q.** ログイン処理とか DB アクセスとか、どすんの？
________

### キャッシュ文脈(**$CON**)
#### の `->prop->{stash}` に入れ
#### Entity 関数で取り出す

```perl
# in app.psgi:
  use Otogiri;
  Entity otogiri => sub {
    my ($this) = @_;
    $CON->prop->{stash}->{otogiri} //= do {
      Otogiri->new(connect_info => ["dbi:SQLite:dbname=$app_root/var/db/site.db"]);
    };
  };
```

#### View calls models.

```xml
<h2>&yatt:otogiri():single(user,{login,:user}){email};</h2>
<ul>
<yatt:foreach my=user list="&yatt:otogiri():select(user);">
  <li>login=&yatt:user{login};</li>
</yatt:foreach>
</ul>
```

--------

## **Q.** なんで doc_root 直下に
## template 置くの？

________

### Direct Mapping(?) 指向

WAF の doc_root の下に, 拡張子 `*.yatt` で置くだけ

ex. `html/index.yatt`

* http://0:5000/index.yatt
* http://0:5000/index
* http://0:5000/

<small>(PHP みたいに！ PHP みたいに！)</small>

________

##### 理由1. **前段で**さばき易くしたい

* try_files ... @upstream ... への疑問
  * Not found が WAF を叩くのは、良いことなの？

##### 理由2. マッピングに関わりたくない

* マッピングは **ビジネスロジック** ！
* ビジネスロジックの変化に付き合いたくない！
  * <small>ファイルの追加で呼び出されるのは勘弁</small>
________

### 理由3. url 抽象化は yatt でも出来るし

(yatt はルータも内蔵)

```xml
<!yatt:args "/:user">
  ... &yatt:user; ...

<!yatt:page "/authors/:id">
  ... &yatt:id; ...
<!yatt:page "/authors/:id/edit">
  ...
```

________

### 隠したい部品は?

* 拡張子を `*.ytmpl` に 
  * (e.g. `layout.ytmpl`)
* 又は doc_root 外に継承先(app_base) を加え、そこに逃がす
  * `(app_base => "$app_root/ytmpl")`
  * テンプレートは Perl のクラスになるので、継承出来る

--------

### **Q.** 何でコード生成？

________

* 後で表現力の不足に悩むのが嫌だから
  * グリーンスパンの第11法則

--------

### **Q.** **`<yatt:foo>...</yatt:foo>`** みたく
### 囲む意味は？

________

### **ruby** の **`do ... end`** ブロック
#### みたいなもの

```xml
<yatt:mytag>
  ...ここが (body という名前の) callback,
     クロージャ引数として mytag に渡される...
</yatt:mytag>
```

mytag の側で呼び出して使う。

```xml
&yatt:body();
```
又は
```xml
<yatt:body/>
```

(⇒ruby の `yield` みたいなもの)

--------

### **Q.** 入れ子はどうするの？

引数内に html タグや widget 呼び出しを書きたくなったら？

```xml
<yatt:foo 
   bar="<em>なんとか</em><i>かんとか</i>"
/>
```

**とは書きたくない**<small>ので、どうするか…</small>

________

### ⇒ lisp や ruby のキーワード引数風に
#### 頭に **`:`** を付けたタグで囲む

**`<:yatt:NAME>〜</:yatt:NAME>`**
```xml
<yatt:foo>
  <:yatt:bar>
    <em>なんとか</em><i>かんとか</i>
  </:yatt:bar>
</yatt:foo>
```

又は **`<:yatt:NAME/>〜`**

```xml
<yatt:foo>
  <:yatt:bar/>
    <em>なんとか</em><i>かんとか</i>
</yatt:foo>
```

--------

### **Q.** Mojolicious/Amon2/Dancer... から使うには？

________

## 要望があれば!
### 取り組みます

--------

### **Q.** 1ファイルアプリを<small>作るには?</small>

________

## 普通の作りじゃ
## 静的検査が効かない

```perl

my $yatt = YATT::Lite->new(vfs => [data => q{
<!yatt:widget foo>
<h2>foo</h2>
<!yatt:widget bar>
<h2>bar</h2>
}]);

$yatt->render(foo => {});
```

(yatt を使う意味が無くなる)

________

### **use YATT::Lite::Embed** <small>(experimental)</small>

`__DATA__` ブロックのテンプレートを静的に検査

```perl
use YATT::Lite::Embed; # This exports $YATT instance.

sub render {
  my ($page, $args) = @_;
  $YATT->render($page, $args);
}

__DATA__
<!yatt:args user>
<h2>Hello! &yatt:user;</h2>
 
<!yatt:page foo user>
This is foo, &yatt:user;
```

See: [gist: hkoba / mojoyatttest.pl](https://gist.github.com/hkoba/5183295fb9260415dc47)

--------

### **Q.** 今さら Perl?

________

## yatt 自体は
## **言語中立**

<small>(原理的上は)</small>

________

## 保存時 **typo 検査** <small>を**高速に**こなせる言語が</small>
### 他に有れば、考えます

`use strict`!

`use fields`!

?nodejs? ?OCaml?


--------

### **Q.** 今さらサーバー側テンプレート？

________

* yatt から JS とか
* yatt から Web Components とか

やりたいですね〜


--------

### **Q.** ほんとに手離れ良くなった？

________

#### hkoba がスタッフさんに
### 呼ばれる回数は
## ちょっと減った

________

### 皆さんモリモリ
## widget 自作してます

`部品化の要求`には応えられた

________

### 何より
## 離職率が下がった! \\(^^)/

________

### でも hkoba は
#### 別プロジェクトでビジネス層に巻き込まれて
### 忙しいままorz...

________

## <a href="http://www.ssri.com/recruit/" alt="ssri.com"><img src="ssri_logo.svg"alt=SSRI> **ssri.com** </a> は
### **Perl** 書きたい人、**募集中** です!

* フリーランスの人でも応相談！
* <small>(アンケート作成スタッフはプログラミング未経験者も歓迎!)</small>

--------

## まとめ

* HTML ネィティブへの直接支援、大事
* 「保存時にtypo箇所にジャンプ」は沼を避ける武器
* [github.com/hkoba/yatt_lite](https://github.com/hkoba/yatt_lite) ご意見待ってます！
