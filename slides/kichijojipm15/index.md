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

## デモ

---

### <small>モジュールを CLI から実行できて</small>嬉しいこと

* 様々な入力パターンを即興で試せる
```sh
% ./MyScript.pm x 10 y 100 -- aaaaaaa bbbb
% ./MyScript.pm x 100 y 30 -- aa bb
```
    * Unit Test を書く以前のテスト
    * REPL の弱い言語<small>(ex. perl)</small>では価値が大
* デバッガで試しやすくなる<small>(ex. perl)</small>
```sh
% perl -d ./MyScript.pm x 100 y 100 -- foo bar
```

---

## 即興で試せる
# ＝楽

---

Runnable Module を書き始めると気づくこと:

### = `main()` 以外も CLI で気軽に試したい

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
% ./MyScript2.pm foo
```

<small>(ファイル名は補完できるから)</small> 実質 8キー程

---

直接にマップすると困る method もある (eg. `import`)  
→ `cmd_XXX` があれば優先させよう([ex2](./ex2/MyScript2.pm))

```perl
sub cmd_import {...}

unless (caller) {
  my $self = __PACKAGE__->new(parse_opts(\@ARGV));

  my $cmd = shift || 'help';

  if (my $sub = $self->can("cmd_$cmd")) {
    $sub->($self, @ARGV);

  } elsif ($sub = $self->can($cmd)) {
    print Dumper($sub->($self, @ARGV));

  } else {
    $self->cmd_help("No such command: $cmd");

  }
}
```

---

`cmd_XXX` は中で print を呼ぶ

一般の method の結果はシリアライズして出力

```sh
% ./MyScript2.pm list_dirs_with_mtime . ..
$VAR1 = {
          'mtime' => 1531301232,
          'dir' => '.'
        };
$VAR2 = {
          'mtime' => 1531283508,
          'dir' => '..'
        };
%         
```

---

デバッガからも method に直行出来て便利

```sh
% perl -d ./MyScript2.pm foo
```

---

Object の属性はどうする？  
← posix style long option で渡すことにしよう


```sh
% ./MyScript2.pm --loglevel=3 foo
```

---

欲が出る

---

### 属性に構造(hash表や配列)を渡したい

```perl
my $obj = MyScript2->new(
  to => ['someone@example.com', 'otherguy@example.com'],
  dbi => ["dbi:SQLite:dbname=foo.db", '', '', {sqlite_unicode => 1}],
);
```

先の仕組みでは CLI から試せない

---

### 構造を期待する method も試したい

```perl
$obj->list_changed_project(
  {project_dir => "/var/www/inst1"},
  {project_dir => "/var/www/inst2"},
);
```

これも、先の仕組みでは CLI から試せない

---

構造を CLI から渡したい

けど引数 eval は危うい、使いどころが減る…

---

eval が駄目なら JSON を使えば良いじゃない？？

---

### JSON らしき引数は deserialize しよう！

```sh
% ./MyScript9.pm --to='["hkoba@cpan.org","foobar@example.com"]' xxx
```

出力も JSON で出す！
```sh
% ./MyScript9.pm list_dirs_with_mtime /var/www/html / | jq .
[
  {
    "dir": "/var/www/html",
    "mtime": 1525164879
  },
  {
    "dir": "/",
    "mtime": 1525583450
  }
]
```

---

### JSON-Aware
### Subcommand-dispatching
### Runnable Module

# 爆誕

---

というパターンが boilerplate 化してきたので  
モジュールにまとめました＞

MOP4Import::Base::CLI_JSON

---

### よくある誤解

---

### `☓` CLI アプリを作るための手法？

↓

### `○` モジュールの開発を楽にするため

* 細部を一つずつ、小さく試せる
* すぐ結果が見られる
* 試した部品を積み上げる, ボトムアップ開発の手段

---

### CLI から呼べるけど

* public からの入力を直接渡すためのものではない。
* あくまで開発支援。
* public 向けのタフな CLI を作ることは out of scope

---

### まとめ

Runnable Module

* `サブコマンド` → `メソッド`
* `オプション` → `属性`

を用意すると捗るよ

デバッグ・プロトタイピング・探索的開発
