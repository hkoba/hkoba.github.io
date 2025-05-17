---
marp: true
title: 再び*HTML書き*を Web の主役にする(?)ための、テンプレートエンジン YATT
description: 私 hkoba（えちこば）がずっと作り続けているテンプレートエンジンについて紹介させて下さい〜
image: https://hkoba.github.io/slides/webnight-miyazaki21/slide.jpg
---

# 再び **HTML書き** を Web の主役(?)にする
## ための、テンプレートエンジン: [**YATT**](https://github.com/hkoba/yatt_lite)

[X: **@hkoba**](https://x.com/hkoba) （えちこば）、フリーランス<small>（一応）</small>

<small>仕事：[Perl](https://metacpan.org/author/HKOBA), Tcl/Tk, GCP 上の Linux サーバー管理etc... TypeScriptは勉強中</small>
<small>ブログ：[hkoba](https://hkoba.hatenablog.com/).hatenablog.com</small>
<small>2023半ば、宮崎移住（木花地区）</small>

---

## 今日の資料 ＞

[hkoba](https://hkoba.github.io).github.io → [`Webナイト宮崎` `#21`](https://hkoba.github.io/slides/webnight-miyazaki21/slide.pdf)

## デモ環境 ＞

github.com/hkoba/[yatt-starter-html](https://github.com/hkoba/yatt-starter-html)

- Dockerfile あります

---

## （…Perl と聞いて、お気づきとは思いますが…）

# 世間のトレンドから、程遠い話です

お許し下さい＞＜

---

### さて本題…

---

# 昔は良かった…

- **HTML を書ける人** なら、誰でも

* **画面の原案** くらいは、自力で作れた

---

# 今の Web は
# 参入ハードルを
# 上げ過ぎでは…？

← https://roadmap.sh/full-stack

![bg left h:80%](img/full-stack-2025-05-06_12-53.png)

---

# 勉強すること、多すぎ！

---

とは言っても、<small>（一定レベル以上の）</small>Webサイトを作るなら

- <small>（静的 or 動的）</small>**テンプレートエンジン** は導入したい

* 理由：HTML だけですら…

  - 見た目の要求水準が上昇 ＝ 記述量が増えた

  * ページごとに書き換える箇所が沢山

    * 手作業だと負荷が大きい・漏れが出る

---
### そして何より、
### 優れたテンプレートエンジンがあると、プログラマーとして
# 仕事の手離れが良くなる

* HTML から先（＝デザイン, コンテンツ, サービス, ビジネスの**個別案件**…）を  
**HTMLを書ける人** に委ねられる

* プログラマ・エンジニアは、汎用的な土台づくりに専念出来る

---

## けど一般的に、
# テンプレートエンジンは…

  * 構文が…まぁまぁ難しい（HTML らしくない）ものが多い

  * 覚えてもらうハードルが高いと、導入しづらい

---

## そこで、
# こんなテンプレートエンジンを作っています

* 極力、HTML らしさを保つ

  - ページの追加は、ファイルをポンと置くだけ
  - タグを自分で定義できる（部品をタグとして定義できる）

* 入力を間違ったら、すぐに lint が知らせてくれる

---

（〜ここで、デモに移動〜）

---

### 繰り返しになりますが、
# テンプレートエンジンは、

# 難しいと、導入しづらい

- 任意のサンプル HTML を

- 適当なファイル名で、**ポンと置くだけ** で、動いて欲しい

  * （初期の PHP 的な世界観）

* **HTML 部品への括り出し** も、同レベルの操作にしたい

---

# YATT の場合

- ファイルを置けば、それが route になる

- HTML 部品の括りだしも、

  * 別のファイルに括りだして、

  * `<yatt:ファイル名 />` タグを書くだけ

     * <small>名前空間は `yatt:` 以外にも設定できます</small>

     * 引数も渡せます: `<yatt:ファイル名 引数="値" ... />`
       - 引数置換は `&yatt:引数;`
       - 引数宣言は `<!yatt:args 引数="型?デフォルト値" ...>`

---

### 詳しくは

[マニュアル](https://yatt-yl-podview-rrdekxdjda-an.a.run.app/mod/YATT::Lite::docs::yatt_manual)をご覧下さい

* <small>`XXX:` あちこち未完ですが…🙇</small>

![bg left h:80%](img/yatt_lite_manual.png)

---

### 細々と、10年以上も…

## そんなテンプレートエンジン YATT を作って、仕事に使ってます〜

Yet Another Template Transpiler - YATT

- [YATT::Lite](https://github.com/hkoba/yatt_lite)  
<small>Perl 版</small>

* [yatt-js](https://github.com/hkoba/yatt-js)  
<small>TypeScript 版, まだまだ開発中（Pre α レベル）</small>

* 皆様のご意見を募集してます！

  - 一緒に Perl 書いてくれる人なども募集中！

  * あと、普通に友達ほしいっす！
