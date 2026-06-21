---
marp: true
theme: beamer
---

# Webナイト宮崎 Vol.22

# Shell（Bash）の苦労（の一部）は 
# Tcl に任せても良いかも？


by [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)

---
# 皆さんに質問

# Bash でどこまで書くか、悩みませんか？ ↓

- ローカルPC への導入手順（git clone 後の setup.sh みたいなやつ）

- CI/CD の中のアクション

- クラウドだけど、一台しか立てないやつ（terraform？ AI が書くから気にしない？）

* **一部は** Tcl に任せても良いかも？

---
# Tcl ってどんな言語？

- Shell に似た構文
  ```tcl
  # 変数代入
  set pattern *.o
  
  #            ↓[...] でコマンド置換
  set fileList [glob -nocomplain $pattern]

  # exec で外部コマンド呼び出し
  exec rm -f {*}$fileList
  ```
  - `"..."` 不要
  - `,` 不要

- Shell 向けのコマンド例が<small>（ある程度）</small>流用できる


---

# Shell(Bash) で苦しんだこと、無いですか？

- 変数名を打ち間違ってもエラーにならない

- エラーが起きても止まらない、残りの行が実行される

- ファイルのパス名とかにスペースが入る時に、書き方に注意が必要

* Tcl なら
  - エラーは例外処理に
  - 値にスペースが入っても、勝手に分割されない

---
# (個人的) Tcl の最推しポイント

# `Dry-Run` や`べき等`、`undo` の仕組みを作りやすい

- `Dry-Run` - 試運転（コマンドを表示するだけ。実行はしない）

- `べき等(idempotent)` - 目標状態を満たしてない時だけ実行（複数回呼んでも安全）


* **構文を簡略化** ＋ **コマンド行（ワード列）を正規化可能なデータ構造に** した、おかげ

---
# Dry-Run - Shell と Tcl を比較

# Shellの場合<small>（ここだけ `Zsh` です）</small> 

任意のコマンドを dry-run 対応にする shell 関数の例
```sh
zparseopts -D -K n=o_dryrun; # -n なら配列 o_dryrun に保存
function x {
    print "# $argv"
    if (($#o_dryrun)); then return; fi; # -n ならここでリターン
    "$argv[@]" || exit $?
}
```

使い方の例
```sh
x rm *.o
```
`-n` オプションが指定されたときは、 rm は実行されない

---

# Shell の Dry-Run の限界

先の仕組みでは dry-run 化できないもの：**リダイレクト**と**パイプ**

```sh
# リダイレクト
x echo foobar > foo.txt

# パイプ
x find -size +10M | xargs rm -f
```

**Shell の組み込み構文** なので、関数の引数にならない

---
# Tcl ではリダイレクト・パイプは exec が解釈する

Tcl ではリダイレクトやパイプは言語の構文**ではない**

```tcl
exec echo foobar > foo.txt

exec find -size +10M | xargs rm -f
```

exec コマンドが **単なる引数** 文字列として `>` や `|` を受け取り、それを解釈して実行

---
# Tcl で Dry-Run の例
```tcl
package require cmdline
array set ::opts [cmdline::getoptions ::argv {
  {n "dry-run"}
}]

proc =RUN args {
    exec -ignorestderr {*}$args 2>@ stderr
}
proc RUN args {
    puts "# $args"
    if {$::opts(n)} return
    # リダイレクトが指定されていない時は stdout へリダイレクト。末尾のみ認識。
    if {[lindex $args end-1] ni {">" ">@" ">>"}} {
        lappend args >@ stdout
    }
    =RUN {*}$args
}
```
---
# Tcl版の使用例

exec を RUN に変えるだけで Dry-Run 化出来る

```tcl
RUN echo foobar > foo.txt

RUN find -size +10M | xargs rm -f
```

変数間違いも、Dry-Run 時点でエラーになる

```tcl
set fileList [glob *.o]

RUN rm {*}$fileListtt;  # ERROR! ここで止まる
```

---
# まとめ

## Bash 全部を置き換える話じゃない

* けど、**仕方なく bash を使っている箇所** の何割かは、置き換えても良いかも？


---
# Bash と Tcl の比較(1/2)

||bash|tcl|
|---|----|----|
|予約語|case do done elif else esac fi for function if in select then until while time|（無し）|
|コメント| `#` から行末まで | コマンド名の位置の `#` から行末まで(ただし { } が優先される) |
|他の特殊文字| \| \& ; \( \) { } [ ] < > $ \` ! \\ * ? = | ; { } [ ] $ \\ |

---

# Bash と Tcl の比較(2/2)

||bash|tcl|
|---|----|----|
|外部コマンドの起動|予約語以外は全て外部コマンドと解釈される| `exec`, `open` コマンドを用いて起動<small>(原則)</small> |
|パイプ<br>・リダイレクト| 構文に組み込み `\|` `<` `>` | `exec`, `open` コマンドの機能 |
|子プロセスの fork|  構文に組み込み `( )` | （外部パッケージ Tclx）|

---

# べき等の例

```tcl
# Google Cloud の現在のプロジェクトの VM の一覧を取得
set vmList [=RUN gcloud compute instances list --format=value(name)]

if {$newVm in $vmList} {
  puts "VM $newVm は作成済み"
} else {
  RUN gcloud compute instances create $newVm ...
}
```

---

# undo の例

```tcl
# @ は順方向のときはそのまま RUN, 逆実行の時は変数 @ に貯めるようなコマンドにしておく
@ gcloud compute networks create $vpcName \
    --project=$project -- \
    --subnet-mode=custom--mtu=1460 ...

@ gcloud compute firewall-rules create $vpcName-allow-icmp-ssh \
    --project=$project \
    -- \
    "--description=google cloud 内部からのみ icmp, ssh を許可" \
    --network=projects/$project/global/networks/$vpcName ...
...
# -R オプションが指定されたときは、逆順に実行
if {$::opts(R)} {
    puts "====================="
    foreach cmd [lreverse [set ::@]] {
        RUN {*}$cmd
    }
}
```
