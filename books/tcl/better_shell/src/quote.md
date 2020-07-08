# quoteと置換の細かい話

## 波括弧とダブルクォートの違い

```tcl
set s Hello
puts "The length of $s is [string length $s]."
# => The length of Hello is 5.

puts {The length of $s is [string length $s].}
# => The length of $s is [string length $s].
```

```tcl
puts [format "Item: %s\t%5.3f" foo 3.8]
# => Item: foo	3.800
```


### コマンド置換 `[..]` は word の要素となる


```tcl
puts [string length foo][string length bar]
# => 33
```

```tcl
[string repeat puts 1] Hello
# => Hello
```

### 空のコマンド置換 `[]` も正当

`[]` は空の文字列を返すコマンド置換です。

```tcl
set s []
# => 
string length []
# => 0
```

### word分割は置換より前に行われる

```tcl
set x 7; set y 9
puts stdout $x+$y=[expr $x + $y]

puts stdout "$x + $y = [expr $x + $y]"
```

## ダブルクォート・波括弧を続けて書くことは禁止

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
