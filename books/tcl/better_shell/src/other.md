## プロシージャ(手続き)

```tcl
proc name arglist body
```

- 変数名とプロシージャ名は、被っても良い

```tcl
proc Diag {a b} {
    set c [expr {sqrt($a * $a + $b * $b)}]
    return $c
}
```


### 階乗計算の例題

```tcl
proc Factorial {x} {
    set i 1; set product 1
    while {$i <= $x} {
        set product [expr {$product * $i}]
        incr i
    }
    return $product
}
```

ファイルに保存して、それを読み込むには

```tcl
source ex1.tcl
```

#### これは駄目、無限ループになる

```tcl
while $i<=10 {incr i; puts $i}
```


## コマンドとして実行可能にするには。

最も単純な書き方だと

```tcl
#!/usr/bin/tclsh

#...

if {![info level] && $::argv0 eq [info script]} {
   puts [Factorial $::argv]
}
```



### 変数名の間接参照

```tcl
set var {the value of var}
set name var
set name
set $name
set [set name]
```


### 普通の識別子以外の変数名

```tcl
set foo filename
set object $foo.o
set a AAA
set b abc${a}def
set .o yuk!
set y ${.o}y
```

### 変数の一覧と、登録抹消

変数の一覧を取得する

```tcl
info vars *
```

名前空間の一覧

```tcl
namespace children
```

名前空間の中の変数一覧

```tcl
info vars ::tcl::*
```


変数の有無を検査する

```tcl
info exists foo
```

変数を削除する

```tcl
unset foo bar
```


### 式(expr) の中で文字列を扱う時


```tcl
expr {$str eq "foo"}
```


### コメント

Tcl ではコメント行を `#` で書きます。他の多くの言語と違って、 
コマンド名部分でしか `#` は効きません。

```tcl
# これはコメント

set # これはコメントじゃない！; # これはコメント

puts [set #]
```

もう一つ重要なことは、 `#` によるコメント化は `{...}` によるグループ化よりも弱い、ということです。


例えば以下はエラーになります。

```tcl
proc Factorial {x} {
    set i 1; set product 1
    while {$i <= $x} {
        set product [expr {$product * $i}]
        incr i
    #}
    }
    return $product
}
```

#### 細かいこと

これはエラー

```tcl
if {$x > 1}{puts "x = $x"}
```

`"` が効果を持つのは、word の先頭の時のみ。途中に出てきた場合は無効


```tcl
set silly a"b c"d
```

`"..."` の中では `{` や `}` の効果(グループ化、quote)は失われる

```tcl
set foo "foo{bar"
set baz "baz {$foo} qux"
```

```tcl
set x [cmd1][cmd2]
```

改行が有っても良い。改行はそのまま保存される

```tcl
set x "foo
bar
baz"
```

これはエラーにならず、 文字 `$` が代入される

```tcl
set x $
```


- - - - -

# リストコマンド

Tclのリストは、Tclコマンドと同じ構造を持つ

```tcl
set x {1 2}
set y foo
set l1 [list $x "a b" $y]
set l2 "{$x} {a b} $y"
```

```tcl
lindex $l1 0
lindex $l2 0
```

ここで x を `{` にしてみると、 `$l2` はエラーになる

リストを組み立てる時は、必ず list などのリスト構築コマンドを使う

## lappend

```tcl
lappend new 1 2
lappend new 3 "4 5"
```


## concat - リストのフラット化(入れ子の解消)


```tcl
set x {4 5 6}
set y {2 3}
set z 1
concat $x $y $z
```


## `{*}..` による、選択的なフラット化

- `{*}` を付けることで、望んだ引数だけをフラット化することが出来る
- コマンドではなくインタープリター自体の機能なので、任意の個所で使える

```tcl
list {*}$x {*}$y $z
```


## llength, lindex, lrange

```tcl
llength {a b {c d} "e f g" h} 

set x {1 2 3 4 5 6}
lindex $x 1
lindex $x end

lrange $x 3 end
```


## linsert, lrepace

```tcl
set x [list a {b c} e d]

lreplace $x 1 2 B C

set x
```

## lsearch

```tcl
lsearch {here is a list} l*

lsearch {here is a list} aaa
```

## lsort

```tcl
set list {a Z n2 n100}

lsort $list

lsort -dictionary $list
```

## split と join

```tcl
set line {this is "not a tcl list}

lindex $line 0

split $line

lindex [split $line] 0

lindex [split $line] 2
```


```tcl
set tsv "foo\tbar\baz"
set list [split $tsv \t]
join $tsv \t
```

tcllib の textutil::splitx

# 制御構造

## if


```tcl
if {条件式} {
  # 条件が真の時
} else {
  # 偽の時
}
```

```tcl
if {条件1} {
  # 条件1が真の時
} elseif {条件2} {
  # 条件2が真の時
...
} else {
  # いずれも偽の時
}
```


## switch

これもオプションが増えている

```tcl
switch -- $value {
  パターン1 { 処理1 }
  パターン2 { 処理2 }
  ...
}
```


- while
- foreach
- for
- break
- continue
- catch
- error
- return


# proc と scope

- デフォルト値
- 可変長引数
- scope
  - global は無し
  - namespace をここで
  - $::var とかも
  
- upvar は欲しそう

- rename ←後回しでは

## array も一応、要るか

- dict の話もしないと

# namespace

- variable
- ::

名前空間の名前と、その中の変数・手続きの名前で事情が異なる

```tcl
::foo::bar
::foo::bar::
::foo::::bar
```


`::` と空文字列は同じ




```tcl

tclsh8.6 [~]namespace eval ::foo::bar {}
tclsh8.6 [~]set ::foo::bar:: 3
3
tclsh8.6 [~]proc ::foo::bar:: {} {puts baz}
tclsh8.6 [~]::foo::bar::
baz
tclsh8.6 [~]puts $::foo::bar::
3
tclsh8.6 [~]namespace eval ::foo::bar {[]}
baz
tclsh8.6 [~]namespace eval ::foo::bar {puts ${}}
3
tclsh8.6 [~]

namespace eval ::foo::bar {
  set {} 3
}
```

# snit

