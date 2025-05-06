# 変数のスコープ

Tcl の変数は、手続きに閉じたスコープを持ちます。
つまり、手続きの中で `set` コマンドを使って作られた変数は
（特別なことをしない限り）その変数の中でのみ有効です。

```tcl
proc foo {} {
  set x foo
  bar
  puts "In foo, x is $x"
}
proc bar {} {
  set x bar
  baz
  puts "In bar, x is $x"
}
proc baz {} {
  set x baz
  puts "In baz, x is $x"
}
```

```tcl
foo
# => In baz, x is baz
# => In bar, x is bar
# => In foo, x is foo
```


## Tcl の変数はブロックスコープではありません

Tcl の構文は `proc`, `if`, `foreach` ... などでスクリプトの固まりを `{..}`
で表現しますが、 C 言語などと違って、変数のスコープはその `{..}` ではなく、
手続き全体になります。


```tcl
proc foobar yn {
  if {$yn} {
    set x FOOO!
  } else {
    set y BARR!
  }
  # info vars は現在のスコープで見える変数名をパターンで検索し返すコマンド
  info vars *
}
```

```tcl
foobar 1
# => yn x
foobar 0
# => yn y
```
