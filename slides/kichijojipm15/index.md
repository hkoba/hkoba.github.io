### 書いて即座に試す
### Runnable Moduleパターン(仮)

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`kichijojipm` `#15`](http://hkoba.github.io/slides/kichijojipm15/)

---

![hatenablog の記事](hatenablog.png)
<!-- https://twitter.com/hkoba/status/905367840663814145 -->


* https://hkoba.hatenablog.com/entry/2017/09/06/185029
* https://github.com/hkoba/perl-mop4import-declare/blob/master/intro_runnable_module.pod

___


おまけ

https://github.com/hkoba/p5-File-AddInc

---

## 内容

* Runnable Moduleパターン(仮)とは？
* 何に役立つか？
* もっと便利にするには？

---

### お断り

* このパターンは広い範囲の言語に適用可能
* ただし、今日は Perl で書きます

---

## Runnable Moduleパターン(仮)<small>とは？</small>

* `モジュール` として利用できる
```sh
# モジュールとしてロードして new し、メソッド foo() を呼ぶ
% perl -I. -MMyScript -le 'print MyScript->new->foo'
```
* かつ、CLI から `コマンド` として実行もできる
```sh
# コマンドとして起動、 MyScript->new(x=>100,y=>100)->main('foo','bar')を呼ぶ
% ./MyScript.pm x 100 y 100 -- foo bar
```


ようにプログラムを書くこと

___

## Runnable Moduleパターン(仮)<small>とは？</small>

* 昔からある
   * Perl 界隈では modulino という呼び名が提唱されている(Brian d foy, 2004).
   * ただし hkoba の記憶ではもっと以前から存在。
   * hkoba は仮に Runnable Module と呼んでいる
* [Stackoverflowで質問してみた](https://stackoverflow.com/questions/51165434/do-the-if-name-main-like-idioms-have-a-name-of-design-pattern) 範囲では、言語を超えた用語は定まっていなさそう。


---

## デモ

---

`MyScript.pm` の中身の例 ([ex1](./ex1/MyScript.pm))

```perl
#!/usr/bin/env perl
package MyScript;
use strict; use warnings;
...

unless (caller) {

   # 超手抜き。 '--' が出るまでを new の引数に、残りを main の引数にする

   my @opts;
   while (@ARGV) {
     last if (my $o = shift) eq '--';
     push @opts, $o;
   }
   my $app = __PACKAGE__->new(@opts);
   $app->main(@ARGV);
}

1;
```

---

### <small>モジュールを CLI から実行できて</small>嬉しいこと

* 様々な入力パターンを即興で試せる
    * REPL の弱い言語<small>(ex. perl)</small>では価値が大
* デバッガで試しやすくなる<small>(ex. perl)</small>
```sh
% perl -d ./MyScript.pm x 100 y 100 -- foo bar
```

---

Runnable Module を書き始めると気づくこと

#### `main()` 以外も CLI で気軽に試したい

---

例: foo() を試すための打鍵数

```sh
% perl -I. -MMyScript -le 'print MyScript->new->foo'
```

`50 文字`

長い、ダルい

---

なら、 **method をサブコマンドに** してしまおう！

```sh
% ./MyScript.pm foo
```

<small>(ファイル名は補完できるから)</small> 実質 8キー程

---

デバッガからも method に直行出来て便利

```sh
% perl -d ./MyScript.pm foo
```

---

ならオプションは Object の属性に

```sh
% ./MyScript.pm --loglevel=3 foo
```

---

## デモ

---

### よくある誤解

___

### 誤解: CLI アプリを作るための手法？

逆。モジュールの開発を楽にするための手法

* 細部を一つずつ、小さく試せる
* すぐ結果が見られる
* 試した部品を積み上げる, ボトムアップ開発の手段

---

### まとめ

Runnable Module

* `サブコマンド` → `メソッド`
* `オプション` → `属性`

を用意すると捗るよ

デバッグ・プロトタイピング・探索的開発
