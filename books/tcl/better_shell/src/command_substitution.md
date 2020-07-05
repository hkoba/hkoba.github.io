# コマンド置換

word の中の `[ .. ]` で表された部分は、更に別のコマンドとして実行され、
その結果が `[ .. ]` の個所に差し込まれます。

```tcl
puts "length of foo is [string length foo]"
```
