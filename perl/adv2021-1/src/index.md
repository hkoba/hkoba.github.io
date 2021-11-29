# はじめに

この記事は [Perl Advent Calendar 2021](https://qiita.com/advent-calendar/2021/perl) の 1日目の記事です。

- - - -

この記事では、モジュールに CLI コマンドとしての機能を兼ねさせるための
コードの書き方について、いくつかのパターンを取り上げ、
それぞれの長所短所を私 hkoba の個人的な経験から論じます。
言語としては主に Perl を取り上げますが、他の言語にも適用可能な部分はあるはずです。

## モジュール兼コマンド（Modulino - モジュリーノ）とは？

この記事で論じる「モジュール兼コマンド」とは、

- 他のプログラムから使われるモジュールとして書かれたコードであり、
- 同時に、単体で CLI コマンドとしても実行可能なもの

のことです。Perl の界隈では、このようなプログラムに
Modulino（モジュリーノ）という呼び名が提唱されています[[brian d foy(2004)](http://www.drdobbs.com/scripts-as-modules/184416165)]。
他の言語における呼び方は、[StackOverflow で質問](https://stackoverflow.com/questions/51165434/do-the-if-name-main-like-idioms-have-a-name-of-design-pattern)した範囲では
見つけられませんでした。
この記事でも、以後は Modulino と表記します。

### Perl で書かれた Modulino の例（※） [Hello.pm](eg-hello/Hello.pm)

```perl
{{#include eg-hello/Hello.pm}}
```

[→ 他の言語の例はこちら](./eg-hello.md)

- - - -
<small>※ 私の Modulino の紹介では、モジュールに `#!` と実行ビットを付与することを前提としています。brian d foy や Gabor Szabo の記事では、そうでないものが多いようです。Windows への配慮なのかもしれませんが、Unix 屋にとっては不便だと考えています。</small>
