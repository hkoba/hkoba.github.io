# はじめに

この記事は [Perl Advent Calendar 2022](https://qiita.com/advent-calendar/2022/perl) の 1日目の記事です。

- - - -

# ある Perl 屋の副業の物語

あなたは時々、副業で Perl 関連の仕事を請けている。
最近は Perl を自ら進んで書く人は減ってしまったが、競争も少ない分買い叩かれることもなく、
悪くない仕事だと思っている。

今回の仕事の内容は、顧客に依頼されたメールサーバーに Perl で書かれたプログラムを導入して設定することだ。導入したいプログラムは [authentication_milter](https://github.com/fastmail/authentication_milter)、初めて知ったプログラムだ。これは CPAN にも [Mail::Milter::Authentication](https://metacpan.org/pod/Mail::Milter::Authentication) として登録されている。対象となるメールサーバーの OS は CentOS Stream 8 だが、このモジュールの rpm はどこにも無いようだ。さて、どうやってインストールするのが良いだろう…？

### 制約条件

- 対象プログラム（authentication_milter）はメールサーバーソフト（postfix）から呼び出され、OS の標準サービスの一部として働く予定だ。

  - そのため、OS添付の `/usr/bin/perl` （いわゆるシステムPerl）を活用したい  
（plenv/ perlbrew/ perl-build などで独自の Perl バイナリーをインストールすることは、運用を他人に引き継いだ後の混乱の元になるという理由で、今回は避けるとする）  
幸い、CentOS Stream 8 の現在の Perl は `v5.26.3`。新しくはないが、使えないほど古いものでもない。

- このサーバーには既に SpamAssassin （これも Perl で書かれている）が OS のパッケージ管理システム dnf を通じて導入されている。この挙動は壊したくない。

- テストサーバー上で authentication_milter を導入し、問題が発覚した時は撤退することで顧客の同意を得ている。ただし、撤退時は完全なアンインストールが必須だ。

