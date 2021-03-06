# コメント（comment）

Tcl でプログラムにコメントを書くには、 **コマンド名の位置の先頭文字に** `#` を書きます。
これにより行末までがコメントアウトされます。

```tcl
# これはコメント
#これもコメント    同じくコメント
   # これもコメント
string repeat これはコマンドの引数 1
```

他のプログラミング言語と違って、コマンドの引数の位置に # を書いても、 **単なる # という文字** として扱われてしまうので、注意して下さい。例


```tcl
string repeat foo 3 # これは文字列を繰り返すコマンドです、と書くとエラー
```
結果は以下↓のように、引数個数間違いのエラーになります。
```
wrong # args: should be "string repeat string count"
while evaluating {string repeat foo 3 # これは文字列を繰り返すコマンドです、と書くとエラー}
```

コマンドの後ろにコメントを続けたい時は、 `;#` のようにコマンドの終わりを指定して下さい。

```tcl
string repeat foo 3;# これは文字列を繰り返すコマンドです
```

