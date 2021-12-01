# はじめに

この記事は [Perl Advent Calendar 2021](https://qiita.com/advent-calendar/2021/perl) の 2日目の記事です。

- - - -

昨日の記事 [モジュール兼コマンド（Modulino - モジュリーノ）再考](https://hkoba.github.io/perl/adv2021-1/book/index.html) では
モジュールに CLI コマンドとしての機能を兼ねさせることの
メリットと、そのためのコードの書き方について解説しました。

この記事では Perl で Modulino を開発の中心に据えた時に遠からず直面する、
ライブラリ・ロードパスの設定の問題と、その解決策として hkoba 作
[File::AddInc](https://metacpan.org/dist/File-AddInc/view/lib/File/AddInc.pod) について解説します。

- - - -

