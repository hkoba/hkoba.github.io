# 変数、手続き、計算式、制御構文

```tcl
set x 3
# => 3
set y 8
# => 8
expr {$x + $y}
# => 11
puts "$x + $y = [expr {$x + $y}]"
# => 3 + 8 = 11
```

```tcl
proc x+y {x y} {
  puts "$x + $y = [expr {$x + $y}]"
}
```

```tcl
x+y 3 8
# => 3 + 8 = 11
x+y 5 10
# => 5 + 10 = 15
```

```tcl
set x 3
# => 3
set y 8
# => 8
expr {$x < $y}
# => 1
expr {$x >= $y}
# => 0
proc < {x y} {
  if {$x < $y} {
    puts "$x is less than $y"
  } else {
    puts "$x is greater than or equal to $y"
  }
}

< 3 8
# => 3 is less than 8
< 8 3
# => 8 is greater than or equal to 3
```
