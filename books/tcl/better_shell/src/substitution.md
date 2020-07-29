# word内の置換

Tcl インタープリターは [word 分割](./tcl_wordbreaking.md) が済んだ後の
それぞれの word に対して、置換と呼ばれる以下の処理を施します。
（ただし波括弧 `{..}` で quote されている word には置換は適用されません）

## コマンド置換

word の中の四角括弧(square bracket) `[ .. ]` で表された部分は、更に別のコマンドとして実行され、
その結果が元々 `[ .. ]` のあった個所に差し込まれます。

```tcl
puts "length of foo is [string length foo]"
# => length of foo is 3
```

コマンド置換の中も一つのコマンドなので、当然それを入れ子にすることも可能です。

```tcl
string repeat [string repeat f 3] 2
# => ffffff
string length [string repeat [string repeat f 3] 2]
# => 6
```

## 変数置換

word の中に `$` で始まる英数字の並びが有れば、それは変数置換の対象となります。
（未知の変数を参照した時は例外が発生し、コマンドの実行はそこで終了します）

変数を作るための最も基本的なコマンドは [`set`](https://www.tcl.tk/man/tcl8.5/TclCmd/set.htm) コマンドです。

```tcl
set var 5

puts "var is $var"
# => var is 5
```


## バックスラッシュ置換

バックスラッシュはコマンド置換の `[` や変数置換の `$` などの
文字をそのまま文字列に書きたい時に使います。
また、C 言語に準じた改行文字 `\n` やタブ文字 `\t` などの記法も
サポートしています。

```tcl
puts "Dollar sign is \$. Open square bracket is \[."
# => Dollar sign is $. Open square bracket is [.

puts Open\ curly\ brace\ is\ \{.
# => Open curly brace is {.
```

### 波括弧 quote `{}` の中では置換は起きない。バックスラッシュは word分割のみに作用

波括弧quote `{}` の中では置換が起きません。これはバックスラッシュについても当てはまります。ただしそれ以前の word 分割で、バックスラッシュは `{...}` の中の
 `{`, `}` を括弧として数えないためにも使われます。
その場合、バックスラッシュは文字としてそのまま残ります。

```tcl
puts {Backslash is kept like \{ and \}.}
# => Backslash is kept like \{ and \}.
puts {Balanced quote is ok like { and }.}
# => Balanced quote is ok like { and }.
```

これはつまり、波括弧 `{...}` の中にはバランスした（＝開き括弧と閉じ括弧が正しく対応した）形でしか `{`, `}` 文字を書くことが出来ないことを意味します。

括弧の対応を無視して `{`, `}` 文字を書きたい時は、ダブルクォート `".."` を使います。

```tcl
puts "open curly brace {"
# => open curly brace {
puts "close curly brace }"
# => close curly brace }
```

### バックスラッシュを用いた行の継続

なお、バックスラッシュは改行をコマンドの終わりとしないためにも使えます。
一つのコマンドの行が長くなりすぎた時に行末を `\` で終わらせると、
そのコマンドの引数の続きを次の行に書くことが出来ます。

```tcl
puts [string repeat foo \
  3
]
# => foofoofoo
```

(注！ tclreadline のバージョンによっては↓以下の例がエラーになりますが、
Tcl のプログラムとしては間違いではありません)

```tcl
string repeat foo \
  3
# => foofoofoo
```
