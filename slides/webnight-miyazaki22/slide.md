---
marp: true
theme: beamer
image: https://hkoba.github.io/slides/webnight-miyazaki22/slide.jpg
---

# Webナイト宮崎 Vol.22

# Shell（Bash）の苦労（の一部）は 
# Tcl に任せても良いかも？
[（→関連blog: Dry-run の実現技法、個人的な定番）](https://hkoba.hatenablog.com/entry/2025/02/08/125644)

by [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)

---
# 皆さんに質問

# Bash でどこまで書くか、悩みませんか？ ↓

- 社内ツールの導入手順（git clone 後の setup.sh みたいなやつ）
  ```sh
  git clone ... && cd ...
  chmod g+ws var var/db
  chown nginx var var/run
  sqlite3 var/db/myapp.db3 < sql/schema.sql
  ```
- CI/CD の中のアクション

- クラウドだけど、一台しか立てないやつ（terraform？ AI が書くから気にしない？）

* Python/Ruby/Node,Deno... で書き直すのはやりすぎ感有るもの（AIが（略）？）

---

# 皆さんに質問

# Shell(Bash) で苦しんだこと、無いですか？

- 変数名を打ち間違ってもエラーにならない

- エラーが起きても止まらない、残りの行が実行される

- ファイルのパス名とかにスペースが入る時に、書き方に注意が必要

* **Tcl なら**
  - エラーは例外処理に（catch 箇所まで脱出）
  - 値にスペースが入っても、勝手に分割されない

---
# Tcl ってどんな言語？

- Shell に似た構文
  ```tcl
  # 変数代入
  set pattern *.o
  
  #            ↓[...] で部分式の呼び出し（コマンド置換）
  set fileList [glob -nocomplain $pattern]

  # exec で外部コマンド呼び出し
  exec rm -f {*}$fileList
  ```
  * 文字列に `"..."` 不要
  * 引数列に `,` 不要
  * リストを展開したい箇所は `{*}` で明示

* Shell 向けのコマンド例が<small>（ある程度）</small>流用できる


---
# (個人的) Tcl の最推しポイント

# コマンド行（List）を操作する体系の上に作られた言語

```tcl
foo bar baz; # コマンド foo に引数 bar baz を渡す

set cmd [list foo bar baz]; # 上記と同じことを表す list を変数 cmd に入れる

{*}$cmd; # 変数に入ったコマンドを実行
```

- 文字列を中心に作り直された lisp 、感（弱点も多いけど…）

* → `Dry-Run` や`べき等`、`undo` の仕組みを被せやすい

  - `Dry-Run` - 試運転（コマンドを表示するだけ。実行はしない）

  - `べき等(idempotent)` - 目標状態を満たしてない時だけ実行（何回呼んでも安全）


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
x rm -f *.o
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

# お断り：Tcl も不満な点は沢山

- 変数が<small>（手続き毎にスコープが隔離されるにも関わらず）</small>動的スコープ

- 静的検査が無い（実行するまで typo すら見つからない）

- 記述が長くなりがち

- lisp ならアレが出来るのに…って不満が沢山出る（少しずつ改善中）

- pip, gem, npm みたいなの無いの？（→ tcllib と tcler's wiki で我慢）

- tclsh に `-e EXPR`, `-c CMD` みたいなオプションが無いのはとても不便

* **全て**を任せる言語じゃない、けど、**雑用**言語としては有益

---
# まとめ

## Bash 全部の置き換えは無理（インストールが要るもんね）

- けど、**仕方なく bash を使っている箇所** の何割かは、置き換えても良いかも？

- メタプログラミングに強い shell と考えると良いかも？

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
