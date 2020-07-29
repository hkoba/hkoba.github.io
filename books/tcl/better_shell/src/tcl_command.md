# コマンド（command）

Tcl の構文はシェルに似ています。Tcl はプログラムをコマンドの並びとして
解釈し実行します。大まかに言えば、一つのコマンドはコマンド名と引数の並びを
一つ以上の空白文字（スペース又はタブ）で挟んで並べたものです。
<small>（先頭や末尾にも空白文字を入れて構いません）</small>
コマンドの終わりは **改行** か `;` で表します。

```tcl
コマンド名 引数1 引数2...
```

コマンドを構成する並びの一つ一つの要素を **word** と呼びます。
例えば以下のコマンドでは `string`, `repeat`, `foo`, `3` が word です。
<small>（[`string repeat`](https://www.tcl.tk/man/tcl8.5/TclCmd/string.htm#M45) は文字列を指定回数だけ繰り返すコマンドです。）</small>

```tcl
string repeat foo 3
# => foofoofoo
```

**word の間の空白文字を省略することは出来ません。**
例えば `string repeat foo 1` の foo と 1 の間の空白文字を省略したつもりで、
こう書いたとします＞

```tcl
string repeat foo1
```

結果は次のようなエラーになります。<small>（このエラーはコマンドの引数が足りないことを意味するエラーです。）</small>

```
wrong # args: should be "string repeat string count"
while evaluating {string repeat foo1}
```

**一行に複数のコマンドを書きたい時は `;` で区切ります。**
以下は `;` を使って一行に複数のコマンドを書いた例です。
<small>（[`puts`](https://www.tcl.tk/man/tcl8.5/TclCmd/puts.htm) は標準出力に文字列を出力するコマンドです）</small>

```tcl
puts foo; puts bar
# => foo
# => bar
```
