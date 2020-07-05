# puts stdout

Tcl で標準出力に文字列を出力するコマンドは `puts` コマンドです。

```tcl
puts Hello
# => Hello
```

上記は以下のコマンドの省略形です。標準出力への書き込みであることを指定するために、stdout を渡しています。

```tcl
puts stdout Hello
# => Hello
```

ここで重要なのは、 `stdout` という文字列自体に特別な機能は無いことです。
同じ文字列を `string length` コマンド（文字列の長さを測る）や `string grange` コマンド（文字列の指定範囲を取り出す）に渡してみましょう。

```tcl
string length stdout
```

このように、Tcl では文字列自体に固有の意味というものはありません。
コマンドに渡された文字列にどんな意味を持たせるかは、そのコマンドの自由です。

