---
marp: true
theme: beamer
image: https://hkoba.github.io/slides/webnight-miyazaki22/slide.jpg
---
<style>
    small {font-size: 70%;}
</style>


# Webナイト宮崎 Vol.22

# Shell<small>（Bash）</small>のツラミ<small>（の一部）</small>は
# Tcl<small>（ティクル）</small>で楽になる、<small>かも？</small>


by [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)


---

# 自己紹介

- [@hkoba](https://github.com/hkoba/)（えちこば） ![](img/myfistrect.jpg)

- 今日のスライド： [hkoba.github.io](https://hkoba.github.io) → [Webナイト宮崎 Vol.22](https://hkoba.github.io/slides/webnight-miyazaki22/slide.html)

- **昨年のWebナイト宮崎 Vol.21**：

![bg right h:400px](img/webnight-miyazaki21.jpg)

* 今日は Shell と Tcl の話


---
# 皆さんへ質問(1/2)

## 雑用を Shell ←vs→ Python etc どっちで書くかの悩み、無いすか？

* 例：**社内ツールの導入手順**
  ```sh
  git clone ... && cd ...
  chmod g+ws var var/db
  chown nginx var var/run
  sqlite3 var/db/myapp.db3 < sql/schema.sql
  ```
  - <u>外部コマンド</u>の呼び出しや<u>ファイル操作</u>の、単なる羅列

  - 他にも：CI/CD の中のアクションとか

  - 短いから Shell で…

---

# 皆さんへの質問(2/2)

# けど、Shell（Bash）で苦しんだこと、無いすか？

* 例：作業ディレクトリへ、データファイルをコピー
  ```sh
  workDir=_build
  
  fileList=*.dat
  
  cp --update $fileListtt $workDir;  # ←変数名間違い！なのにコマンド実行！
  
  ...                                # なのに停止しない！実行が続いてしまう！
  ```
  - **変数名の打ち間違い** がエラーにならなず、実行されちゃう！
  - エラーが起きても**停止しない！**
  - 他にも：<u>ファイル名にスペース</u>が入る時に、書き方に注意が必要
* そんな悩みに、**Tcl**！

---
# Tcl ってどんな言語？

- Shell に似た構文
  ```tcl
  # 変数代入
  set workDir _build

  #            ↓glob はワイルドカードにマッチするファイルのリストを返すコマンド
  set fileList [glob -nocomplain *.dat]

  # exec で外部コマンド呼び出し（{*} はリスト展開）
  exec cp --update {*}$fileList $workDir
  ```
  - 文字列に `"..."` 不要、引数の区切りに `,` 不要<small>（Shell に**近い書き味**）</small>
  * Shell 向けの**コマンド例が流用できる**<small>（ある程度）</small>

* 変数名・コマンド名の間違いは**即エラーで停止**、例外処理へ


---
# (個人的) Tcl の最推しポイント

- コマンドとリストが同じデータ構造
  ```tcl
  foo bar baz; # コマンド foo に引数 bar baz を渡す
  
  set cmd [list foo bar baz]; # 上記の処理を表す list を変数 cmd に入れる
  
  {*}$cmd; # 変数に入ったコマンドを実行
  ```

* つまり：**コマンドを操作するコマンド**を作りやすい

* → `Dry-Run` や`べき等`、`undo` の仕組みを作りやすい

  - `Dry-Run` - 試運転（コマンドを表示するだけ。実行はしない。`make -n`）

  - `べき等(idempotent)` - 目標状態を満たしてない時だけ実行（何回呼んでも安全）

---
# 比較

# Dry-Run を題材に

# Shell と Tcl を比較します

---
# Dry-Run の実装例：Shellの場合

例： `clean-backup.zsh` <small>（ここだけ `Zsh` です）</small>
```sh
#!/bin/zsh
emulate -L zsh; setopt no_no_match
zparseopts -D -K n=o_dryrun; # -n なら配列 o_dryrun に保存
function x {; # `-n` オプションで dry-run にする shell 関数 `x`
    print "# $argv"
    if (($#o_dryrun)); then return; fi; # -n ならここでリターン
    "$argv[@]" || exit $?
}
#==== 以下、やりたいこと ====
x rm -f *.bak
```
使い方
```sh
./clean-backup.zsh -n
# rm -f ファイル… を表示するけど、実行はしない
```

---

# Shell の Dry-Run の限界

先の仕組みでは dry-run 化できないもの：**リダイレクト**と**パイプ**

```sh
# リダイレクト
x echo foobar > foo.txt

# パイプ
x find -size +10M | xargs rm -f
```

`>` `|` は **Shell の組み込み構文** → 関数の外側で動いてしまう

---
# Tcl ではリダイレクト・パイプは exec が解釈する

Tcl ではリダイレクトやパイプは言語の構文**ではない**

```tcl
exec echo foobar > foo.txt

exec find -size +10M | xargs rm -f
```

exec コマンドが **単なる引数** 文字列として `>` や `|` を受け取り、それを解釈して実行

---
# Dry-Run の実装例：Tcl版

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
    # 最後の手前の引数にリダイレクトが指定されていない時は stdout へリダイレクト
    if {[lindex $args end-1] ni {">" ">@" ">>"}} {
        lappend args >@ stdout
    }
    =RUN {*}$args
}
```
---
# Tcl版の使用例

exec を RUN に変えるだけ: **リダイレクト**と**パイプ** も OK

```tcl
RUN echo foobar > foo.txt

RUN find -size +10M | xargs rm -f
```

変数間違いも、Dry-Run 時点でエラーになる

```tcl
set fileList [glob *.bak]

RUN rm {*}$fileListtt;  # ERROR! ここで止まる
```

---

# お断り：Tcl にも弱点・不満は沢山〜

- 動的スコープなのに厳格 ← Shell慣れした人のつまずきポイント

- 静的検査が無い（実行するまで typo すら見つからない）

- 記述が長くなりがち

- pip, gem, npm みたいなの無いの？（→ [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md) と [tcler's wiki](https://wiki.tcl-lang.org/) で我慢）

- tclsh に `-e EXPR`, `-c CMD` みたいなオプションが無いのはとても不便

- **全て**を任せる言語じゃない、けど、**雑用**言語としては有益

---
# まとめ（伝えたいこと）

- Tcl は **コマンド行に対するメタプログラミング** が出来る Shell風言語！！？

  - （大げさに言えば、Lisp をコマンド文字列のために再設計したかのような…）

- もちろん Bash **全部**の置き換えは**無理**

  - インストールが要るから

* けど **仕方なく bash を使っている箇所** の<u>何割か</u>は、置き換えても良いかも？

* ご清聴、ありがとうございました〜〜


---
# 関連記事

## 以前の blog: [→ Dry-run の実現技法、個人的な定番](https://hkoba.hatenablog.com/entry/2025/02/08/125644)


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
