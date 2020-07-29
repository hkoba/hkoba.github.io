# Tclでは、コマンドという語は多義的に使われます

Tcl ではコマンドという語が指すものが文脈によって変化します。

例えば以下のような Tcl プログラムが有ったとします。

```tcl
string repeat foo 3
string repeat bar 2
```

- コマンド名（この場合は `string` 、又は `string repeat`）

- その実体、呼ばれて実行されるもの。<small>（ C で実装された `StringReptCmd`）</small>

- 引数列も含めた一回の実行コマンド。<small>（`string repeat foo 3` 、 `string repeat bar 2` それぞれ）</small>

- 複数のコマンドの並びをグループにまとめた全体。

状況に応じて、意味を判断しながら読んで下さい。
