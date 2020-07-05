# 波括弧とダブルクォートの違い

```tcl
set s Hello
puts "The length of $s is [string length $s]."
puts {The length of $s is [string length $s].}
```

```tcl
puts [format "Item: %s\t%5.3f" foo 3.8]
```


### 四角括弧は引数を分割しない

```tcl
puts [string length foo][string length bar]
```

```tcl
[string cat ex][string cat pr] 3 + 4
```


### 引数分割は置換より前に行われる

```tcl
set x 7; set y 9
puts stdout $x+$y=[expr $x + $y]

puts stdout "$x + $y = [expr $x + $y]"
```

## ダブルクォート・波括弧は連続できない

以下のプログラムは全て word分割の段階で `extra characters after close-quote` エラーになります。(puts コマンドが実行される前のエラーです)

```
puts "foo""bar"

puts "foo"{bar}

puts {foo}{bar}

puts {foo}"bar"

puts {foo}bar
```


## wordの途中にダブルクォート・波括弧を書いても quote 効果は生じない

恐るべきことですが、こうなります。

```tcl
puts foo{bar

puts foo}bar

puts foo{bar

puts foo"bar

puts foo"bar"

puts foo"bar}
```
