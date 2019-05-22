## Perl で Language Server を

### 書いてる話

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`Gotanda.pm` `#19`](http://hkoba.github.io/slides/gotandapm19/)

---

## お断り

* LSP の厳密な話は[公式サイト](https://microsoft.github.io/language-server-protocol/)をご確認下さい

---

### 自己紹介: hkoba

* <small>(名ばかりの)</small>フリーランス・プログラマ
* <small>Perl用のテンプレートエンジン</small><br>
[YATT::Lite](https://github.com/hkoba/yatt_lite#yattlite---template-with-use-strict-) <small>を作ってます。(→[簡単な紹介](../langimpl1/index.html#/))</small>

___


<small>1998 の The Perl Conference Japan で<br>
lwall にセーラームーンのポスターをプレゼントしたことも…</small>

[![](img/ascii-perl-conference-ss.jpg)](https://ascii.jp/elem/000/000/313/313635/)


---

## あらすじ

1. Language Server (<em>LS</em>) とは
2. 今回書いた LS の概要
3. どうやって開発したか？

---

## 1. [Language Server (<em>LS</em>)](https://langserver.org/) とは

---

### [Language Server (<em>LS</em>)](https://langserver.org/) とは

* [Microsoftが提唱](https://microsoft.github.io/language-server-protocol/)している、
* 言語の開発支援ツールを
* エディタから独立して実装するための枠組み
* <p><small>そのための通信プロトコル: `LSP(Language Server Protocol)`</small></p><!-- .element: class="fragment" -->


---

### 言語の開発支援機能とは

* 関数の定義個所へのジャンプ
* 引数仕様の確認
* 構文エラーの検出と通知
* …

---

### LSP が無かった頃


<img style="float: right;" src="img/when-no-lsp.jpg">
<small class="xx-justify-left">
`言語の開発支援ツールを書く人`の悩み：<br>
様々なエディタをサポートしたいが、<br>APIが全部違う<br>
<br>
<br>
`エディタ開発者`の悩み:<br>
様々な言語の開発支援ツールをサポートしたいが、<br>APIが全部違う
</small>


* 組合せに個別に対応する無駄が起きていた。

- - - - -
<small>図の出典: [VSCode - Language Server Extension Guide](https://code.visualstudio.com/api/language-extensions/language-server-extension-guide)</small>

---

### LSP 登場

![](img/when-lsp.jpg)

* <small>LS (LSP サーバー) = 開発支援機能を LSP に基づき提供する</small>
* <small>エディタ (LSP クライアント) = LSP に基づき LS の開発支援機能を利用</small>

---

## 2. 書いた<small>(書いてる)</small> LS の概要

---

### 今回書いた<small>(書いてる)</small> LS

* <small>自作テンプレートエンジン</small> [YATT::Lite](https://github.com/hkoba/yatt_lite#yattlite---template-with-use-strict-) の LS


[YATT::Lite::LanguageServer](https://github.com/hkoba/yatt_lite/blob/dev/Lite/LanguageServer.pm)

- - - -
<small>(※ まだ github のみ公開, CPAN はもっと先…)</small>

___

接続を確認したエディタ(LSPクライアント)

* Emacs (emacs-lsp)
* VS Code

---

#### YATT の構文<small>をサラッと</small>

![テンプレートの例](img/yatt_intro_example.png)

___

#### テンプレート＝部品(widget)の定義の並び

![widget 定義](img/yatt_intro_def.png)

___


#### 部品は名前空間付きタグで呼び出す

![widget 呼び出し](img/yatt_intro_call.png)

___

#### 変数(引数)の参照は Entity Reference 記法で書く

![変数参照](img/yatt_intro_varref.png)

---

## デモ

---

### 動いた<small>(<em>※</em>)</small>API

<dl>
<dt>[textDocument/hover](https://microsoft.github.io/language-server-protocol/specification#textDocument_hover)</dt>
<dd class="small">カーソル下の記号の概要を表示</dd>
<dt>[textDocument/implementation](https://microsoft.github.io/language-server-protocol/specification#textDocument_implementation)</dt>
<dd>定義個所へのジャンプ</dd>
<dt>[textDocument/publishDiagnostics](https://microsoft.github.io/language-server-protocol/specification#textDocument_publishDiagnostics)</dt>
<dd>構文エラーを LS からエディタへ通知</dd>
<dt>[textDocument/didChange](https://microsoft.github.io/language-server-protocol/specification#textDocument_didChange)</dt>
<dd>エディタ上の更新をリアルタイムで受信</dd>
</dl>

- - - - -

<small>(<em>※</em> もちろん未実装・不具合も有りますヨ！)</small>


---

### 3. どう開発を進めたの？

* 大方針
* 具体的な進め方

---

### 大方針

1. `実行より前に` typoを検出可能な書き方<br>
<small>(method not found を減らす)</small>
2. <small>CLIで</small>`任意のメソッドをサブコマンド`<small>として呼べるように</small><br>
<small>(REPL の代わり。デバッガも呼びやすくなる)</small>


---

### 1. 
### `実行より前に` 
#### typoを検出可能な書き方

___

* LSP (JSON RPC) は沢山の型を扱う<small>(ClientCapabilities, ServerCapabilities, TextDocumentIdentifier, Range, Position, ...)</small>
* Perl の普通の OOP では、メンバーアクセスの typo は実行時までエラーを検出できない
  * <small>そもそも bless したら JSON 変換が手間</small>


- - - - 

→ [`fields.pm`](https://metacpan.org/pod/fields) ＋ 生HASH アクセスで<br>
コンパイル時に typo 検出


___

### fields + 生 HASH

```perl
package Position { use fields qw/line character/ };
...
my Position $pos = +{};
$pos->{line} = 3;
$pos->{character} = 8;
```

* <small>`line`, `character` の typo はコンパイル時に静的に検出できる</small>
* <small>エディタの保存時に lint かけて、エラー個所へジャンプさせる</small>

___

### fields の注意点

* 冗長な書き方が必要
```perl
my Position $p = +{line => 3, characterrrrr => 8} # XXX typo を見つけてくれない
```

* 型の mismatch は検出してくれない
```perl
sub pos_of_x { ...; my Position $pos =...; return $pos }
sub range_to_something { (my Range $range) = @_;  ... }
range_to_something(pos_of_x()); # XXX 見つけてくれない
```

- - - -

それでも、無いよりはマシ！

---

## 2. <small>CLIで</small>
### `任意のメソッドをサブコマンド`
#### <small>として呼べるように</small>

___

* <small>書いたら即 CLI から試す</small>
  ```perl
  % ./lib/YATT/Lite/LanguageServer.pm lspcall__textDocument__hover '{
    "position":{"line":11,"character":10},
    "textDocument":{"uri":"file://'$PWD'/public/test.yatt"}
  }'|jq .
  ```
  ```json
  [
    {
      "contents": {
        "kind": "markdown",
        "value": "(widget) <yatt:foo\n  x=text\n   y=text\n   body=code\n\n/>\n"
      }
    }
  ]
  ```
  * <small>メソッド名の typo はこの時点で分かる</small>
* <small>`perl -d` を足すだけで即座にデバッガに入れる</small>

___

* `*.pm` に `#!.. perl` を入れて、実行可能に
* `unless caller` で、サブコマンドから任意のメソッドを起動可能に
* (CLI 起動時の) `出力は JSON で統一`
* 引数も `{}`, `[]` を JSON として自動デコード

- - - - -

<small>詳しくは [MOP4Import::Base::CLI_JSON](https://github.com/hkoba/perl-mop4import-declare/blob/master/Base/CLI_JSON.pod) をご参照下さい</small>

---

### 具体的な進め方

---


1. `参考になる実装`を探し読み解く
2. エディタから LS を起動できる状況を作り、
[initialize](https://microsoft.github.io/language-server-protocol/specification#initialize) を受け取れるようにする
3. プロトコル`仕様書を機械可読な形に`変換する
4. Perl の `型情報(fields)を生成` する
5. まずは [hover](https://microsoft.github.io/language-server-protocol/specification#textDocument_hover) を動くようにする。
   * <small>そのために必要なら、言語の構文木の実装も改良する</small>


---

### 参考にした実装

[Perl::LanguageServer](https://metacpan.org/pod/Perl::LanguageServer)

* 割とベタな書き方だった<small>(ex. [mainloop](https://metacpan.org/release/Perl-LanguageServer/source/lib/Perl/LanguageServer.pm#L233))</small><br>
→読み解いて、自分流に書き直す<small>(ex. [mainloop](https://github.com/hkoba/yatt_lite/blob/22b59cd9c36029e4bab0b4731acafd538f82ab96/Lite/LanguageServer/Generic.pm#L97))</small>

* 初手は JSON RPC 部分から。<small>[こんな感じ](https://github.com/hkoba/yatt_lite/commit/2103016f3da9d92b7a8151e10442c7d42068bcfb)で。</small>

---

### エディタから LS を起動できる状況を作る

* <small>(今の)</small> emacs-lsp なら少し書くだけで ok. <br>
(ex. [lsp-yatt](https://github.com/hkoba/yatt_lite/blob/dev/elisp/lsp-yatt.el))
* VS Code の場合は最初に公式ガイドの [GET STARTED](https://code.visualstudio.com/api/get-started/your-first-extension) でツール環境を整えた後、[LS拡張ガイド](https://code.visualstudio.com/api/language-extensions/language-server-extension-guide)に進む


---

### プロトコル仕様書を<small>(使うところだけでも)</small>機械可読に変換する

* （固い仕様があるのに）通信プロトコルの Request/Response オブジェクトを手で実装するのは
ミスの元
* 計算機の力を使いたい。
* [元の仕様書](https://github.com/Microsoft/language-server-protocol/blob/gh-pages/specification.md)は markdown で、その中に typescript で宣言が書かれている
   * ↑これの json 版とか、無いのかしら？

___

* 仕様書の json 版は、見つけられず。
   * <small>絶対にどこかに有るはず、とは思いつつ…</small>
* **不完全でも良い** から、Perl で変換してみる<br>
[YATT::Lite::LanguageServer::SpecParser](https://github.com/hkoba/yatt_lite/blob/dev/Lite/LanguageServer/SpecParser.pm)

___

まず markdown の codeblock のうち、言語ID が typescript である個所を抜き出す

```shell
./SpecParser.pm extract_codeblock typescript specification.md |
```

次に文(`interface`, `namespace`)の一覧を抜き出す。

```shell
./SpecParser.pm cli_xargs_json extract_statement_list |
```

<small>(型の注釈コメントも残しておく)</small>

___

雑に（文を把握できる範囲で）トークンに分解する

```shell
./SpecParser.pm cli_xargs_json --slurp --single tokenize_statement_list |
```

文を解析して、仕様を表すレコードに変換する
```shell
./SpecParser.pm cli_xargs_json --slurp --single parse_statement_list |
```

___

実は <small>`interface ParameterInformation`</small> だけは手抜きで parse 出来ないので、
`grep -v` で除外^^;

全体はこう＞

```shell
./SpecParser.pm extract_codeblock typescript specification.md |
./SpecParser.pm cli_xargs_json extract_statement_list |
grep -v 'interface ParameterInformation'|
./SpecParser.pm cli_xargs_json --slurp --single tokenize_statement_list |
./SpecParser.pm cli_xargs_json --slurp --single parse_statement_list |
jq --slurp . | fx
```

---

次に、ここから Perl の静的検査に使える情報([fields](https://metacpan.org/pod/fields),[constant](https://metacpan.org/pod/constant))を生成

- - - - -

<small>※具体的には自作のタイプビルダー [MOP4Import::Types](https://github.com/hkoba/perl-mop4import-declare/blob/master/Types.pod) 用の宣言を生成。</small>

___


生成結果→ [YATT::Lite::LanguageServer::Protocol](https://github.com/hkoba/yatt_lite/blob/dev/Lite/LanguageServer/Protocol.pm)

```perl
use MOP4Import::Types
...
'ClientCapabilities' => [
  [
    'fields',
    'workspace',
    'textDocument',
    'experimental',
  ],
],
...
```

- - - - -

<small>※今回のLS に使ったものしか変換していません</small>

---

### Hover を作る

* マウスカーソルの[位置](https://microsoft.github.io/language-server-protocol/specification#position)<small>(ex. `{line: 3, character: 8}`)</small> がエディタから与えられる
* その場所のシンボルを割り出す
* シンボルから、hover で出すべき開発支援情報を作って返す

- - - -

<small>※構文木に十分な情報が残っていない場合は、元の言語の構文木自体も改良する</small>


---

### まとめ

* LSP の概要
* <small>私が辿った</small>LS 開発の流れ

- - - - -

* 動くと楽しい LS、皆さんも作ってみませんか？<!-- .element: class="fragment" -->
* <p><small>Perl屋さんへ:</small>`fields + 生HASH`<small>良いよ！</small></p><!-- .element: class="fragment" -->
