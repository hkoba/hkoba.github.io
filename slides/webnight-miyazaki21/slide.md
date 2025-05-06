---
marp: true
---

# 再び **HTML書き** が Web の主役になる(?)
## ための、テンプレートエンジン: [**YATT**](https://github.com/hkoba/yatt_lite)

[X: **@hkoba**](https://x.com/hkoba) （えちこば）、github.com/[hkoba](http://github.com/hkoba/)

---

## 今日の資料 ＞

[hkoba](https://hkoba.github.io).github.io → [`Webナイト宮崎` `#21`](https://hkoba.github.io/slides/webnight-miyazaki21/slide.md)

## デモ環境 ＞

github.com/hkoba/[yatt-starter-html](https://github.com/hkoba/yatt-starter-html)

- Dockerfile あります

---

## （…Perl と聞いて、お気づきとは思いますが…）

# 世間のトレンドから、程遠い話です

お許し下さい＞＜

---

## デモしながら
## ぼやきを垂れ流します

---

# 昔は良かった…

- **HTML を書ける人** なら、誰でも

* **画面の原案** くらいは、自力で作れた

---

# 今の Web は
# 参入ハードルを
# 上げ過ぎでは…？

https://roadmap.sh/full-stack

![bg left h:80%](img/full-stack-2025-05-06_12-53.png)

---

とは言っても、Webサイトを作るなら

- **テンプレートエンジン** は不可欠

- 理由：HTML だけですら…

  * 見た目の要求水準が上昇 ＝ 記述量が増えた

  * ページごとに書き換える箇所が沢山

---

# けどテンプレートエンジンは…

  * 構文が…まぁまぁ難しい（HTML らしくない）

  * エンジンのための環境構築も、まぁまぁ難しい

---

## （老兵の私が）
# テンプレートエンジンに求めること

* ヘッダ・フッタなどの **繰り返し要素を**、分かりやすく、**部品に**したい
  - **自力で**出来ること！（他のプログラマーに頼むのは無し）

* 書き方を間違ったら、早めに教えて欲しい

---

# 難しいと、始めづらい

- 任意のサンプル HTML を

- 適当な名前でコピーして置くだけで、動いて欲しい

---

## そこを何とかしたくて
## 作っているテンプレートエンジンが、 YATT です

- YATT::Lite  
<small> (Perl 版)</small>

* yatt-js  
<small> (TypeScript 版, 開発中)</small>

* 皆様のご意見を募集してます！
  - 一緒に Perl 書いてくれる人なども募集中！
