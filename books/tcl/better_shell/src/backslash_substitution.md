# バックスラッシュ置換

```tcl
set dollar \$foo
set x $dollar

set newline \n
```

## バックスラッシュを用いた行の継続

```tcl
set one fooo
set two bar
set totalLength [expr [string length $one] + \
  [string length $two]]
```

