# puts stdout 文字列

先程も使ったように、Tcl で標準出力に文字列を出力するコマンドは [`puts`](https://www.tcl.tk/man/tcl8.5/TclCmd/puts.htm) コマンドです。

```tcl
puts Hello
# => Hello
```

上記は以下のコマンドの省略形です。標準出力への書き込みであることを指定するために、stdout を渡しています。

```tcl
puts stdout Hello
# => Hello
```

## 全ては文字列 (EIAS - Everything Is A String)

ここで重要なのは、 `stdout` という文字列は、
他の言語で言うような予約語ではないことです。 **Tcl に予約語はありません**。
 stdout は単なる文字列で、
それ自体に特別な機能はありません。
puts が第一引数を出力先チャネルの名前として扱うに過ぎません。
同じ文字列 stdout を別のコマンド [`string length`](https://www.tcl.tk/man/tcl8.5/TclCmd/string.htm#M37) （文字列の長さを測る）や [`string range`](https://www.tcl.tk/man/tcl8.5/TclCmd/string.htm#M44) （文字列の指定範囲を取り出す）に渡してみましょう。

```tcl
string length stdout
# => 6
string range stdout 0 2
# => std
```

このように、Tcl では文字列自体に固有の意味というものはありません。
コマンドに渡された文字列にどんな意味を持たせるかは、そのコマンドの自由です。

