# コマンドのword分割とquote

次に **Hello World** と表示したいとします。試しに↓こう書いて実行してみて下さい。

```tcl
puts stdout Hello World
```

結果は下記↓のように、引数の個数が違う(wrong number of arguments)というエラーになります。
```error
wrong # args: should be "puts ?-nonewline? ?channelId? string"
while evaluating {puts stdout Hello World}
```

puts コマンドは <small>(-nonewline というオプションを除けば)</small> 出力先チャネル名、そして文字列の２つしか引数を受け付けません。そこに３つの引数を渡したことになり、エラーとされたのです。

このように空白を含んだ文字列を一つの引数として渡したい時は、 
Tcl インタープリタが word分割を行なう時にそれを一つのwordとして
認識してもらえる書き方を用いる必要があります。

スペースを含んだ文字列を一つの word として書く方法は３つあります。
一つはダブルクォート `".."` で囲む書き方、
一つは スペースの前にバックスラッシュ `\ ` を使う書き方、
最後の一つは  波括弧(curly brace) `{..}` で囲む書き方です。

```tcl
puts stdout "Hello World"

puts stdout Hello\ World

puts stdout {Hello World}
```


最初の２つで書かれた word の中では、次に説明する[置換](./substitution.md)
が適用されます。それに対して curly brace 波括弧 `{..}` で書かれた word は
置換が適用されません。
