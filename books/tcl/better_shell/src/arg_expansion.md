# wordの引数展開

コマンドの中の word が `{*}` で始まっている場合、word の残る文字列全体が
Tcl のリストとして解釈され、引数のリストに展開されます。
これは可変長の引数を渡したり、複雑な並びを持った Tcl のリストを直接的に
構築するために役立ちます。

以前の節で扱った例を（作為的ですが）展開を使うように書き直した例を以下に挙げます。


```tcl
set bar {repeat foo}
string {*}$bar 3
# => foofoofoo
```

```tcl
set args [list foo 3]
set cmd [list string repeat {*}$args]
puts $cmd
# => string repeat foo 3
{*}$cmd
# => foofoofoo
```

```tcl
puts {*}{
  stdout
  {Hello world}
}
# => Hello world
```
