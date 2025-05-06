# 実行可能なスクリプトファイル

次に、一つのプログラムとして実行可能な Tcl スクリプトを書く例です。

以下の内容を `echo.tcl` という名前で保存して下さい。  
<small>（これは実行時の引数 `$::argv` を Tcl リストとして標準出力に出力するだけのスクリプトです）</small>

```tcl
#!/usr/bin/tclsh
puts stdout $::argv
```



ファイルを保存したら、（tclsh ではなく）元のシェルの端末で以下を実行して下さい。

```console
% chmod +x echo.tcl
```

これで、端末から `echo.tcl` が起動可能になりました。

```console
% ./echo.tcl foo
foo
% ./echo.tcl bar
bar
% ./echo.tcl foo "bar baz"
foo {bar baz}
```
