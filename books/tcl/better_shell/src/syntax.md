# Tclの構文と評価ルール

この章では Tcl のプログラムの構造の読み方(＝構文：syntax)と、それが Tcl にとってどんな意味を持つと解釈され評価・実行されるのか（＝意味論：semantics）について学びます。公式マニュアルの [Tcl の章](https://www.tcl.tk/man/tcl8.5/TclCmd/Tcl.htm) に相当する内容です。

## 解釈？評価？それって誰が？

XXX: TBW


## 構文を要約すると、Tcl のプログラムは：

- [`#` コメント](comment.md)か、

- [コマンド](tcl_command.md)の集まりです。それぞれのコマンドは：

  - （適切に quote された）[word の集まりへと分割](word_breaking_and_quoting.md)されます。それぞれのword の中は：

    - 以下のいずれかの[置換](substitution)か、

      - コマンド `[]` 置換
      - 変数 `$` 置換
      - バックスラッシュ `\` 置換

    - 只の文字列です。

  - word の先頭が `{*}` 始まっている場合は、[引数展開](arg_expansion.md)が適用されます。
