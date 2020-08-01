# Tclでは、コマンドという語は多義的に使われます

Tcl ではコマンドという語が指すものが文脈によって変化します。

例えば以下のような Tcl プログラムが有ったとします。

```tcl
puts foo
string repeat bar 2
```

この時、コマンドという語が指すものは、以下の可能性が挙げられます。

- コマンド名（この場合は `puts` 、`string` あるいは `string repeat`）

- その実体、呼ばれて実行されるもの。<small>（ C で実装された `Tcl_PutsObjCmd`, `StringReptCmd`）</small>

- 引数列も含めた一回の実行コマンド。<small>（`puts foo` 、 `string repeat bar 2` それぞれ）</small>

- 複数のコマンドの並び <small>（全体）</small>

状況に応じて、意味を判断しながら読んで下さい。
