# word列と Tcl リスト

Tcl には Tcl リスト（以後、リストと呼びます）と呼ばれるデータ表現の仕組みがあります。リストは Tcl プログラムの解釈・実行の中で中心的な役割を演じます。というのも、コマンドの節で挙げた word列がリストだからです。（厳密には、Tcl の解釈する

コマンドを構成する word列は、後述の [置換](./substitution.md)と[展開](./arg_expansion.md)を経て、 Tcl リストになります。

リストは以下のような文字列の並びです
```
word1 word2 word3...
```

* 各 word は、後に説明する [word分割](./word_breaking_and_quoting.md)、[置換](./substitution.md)、[展開](./arg_expansion.md)に関わる文字でない限り、そのまま書くことが出来ます。
* そうでない文字を含む word は、[quote](./word_breaking_and_quoting.md) される必要があります。
* 空文字列もリストです。quote 記法で  `""`  `{}` と書きます。


リストを構築する一番簡単なコマンドは `list` です。

```tcl
list foo bar   baz
# => foo bar baz
```

もう一つの例として、リストの入った変数に要素を追加する、 `lappend` コマンドを挙げます。

```tcl
lappend x foo bar
# => foo bar
lappend x baz
# => foo bar baz
```

Tcl のリストは YAML や JSON、S式などのような、シリアライズフォーマットです。
リストを効率的に格納・操作するための内部データ構造とコマンドが揃っています。

これはコマンドを組み立てるコマンドを書くためにリスト操作のコマンド群を活用できることを意味しています。


