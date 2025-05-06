# 手続き(procedure)

Tcl では、ユーザーの定義したコマンドを手続き（procedure）と呼びます。
手続きを定義するには `proc` コマンドを用います。<small>（手続きを定義することも、コマンドの実行なのです。Tcl には宣言という概念が存在しません。良くも悪くも…）</small>

```tcl
proc 手続きの名前 引数のリスト スクリプト本体
```

手続きは、 `return` コマンドに渡された値か、
最後に実行したコマンドの結果を返します。

例えば、引数で指定された回数だけ foo を繰り返した文字列を返す手続き `foo` を
定義してみましょう。

```tcl
proc foo c {
  string repeat foo $c
}

# return を使って、以下のように書くことも出来ます。最終結果は同じです。
proc foo c {
  return [string repeat foo $c]
}
```

以下は実行例です：

```tcl
foo 3
# => foofoofoo
foo 8
# => foofoofoofoofoofoofoofoo
```

## 引数を複数渡したい時

複数の引数を宣言したい時は、Tcl リスト形式で指定します。今度は繰り返す文字列も
引数で指定できるようにした手続き `repeat` を定義してみます。

```tcl
proc repeat {str cnt} {
  string repeat $str $cnt
}
```

以下は実行例です：

```tcl
repeat bar 3
# => barbarbar
```
