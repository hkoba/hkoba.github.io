# ObjectのnewとメソッドのDispatch

モジュールがコマンド行から起動された時に、
そのモジュールの定義するクラスのオブジェクトを new し、
更に第一引数に基づいてメソッドの呼び出しを行う、という方法です。

（私はこのパターンを、 **OO Modulino** と呼んでいます）

以下の例ではサブコマンド名 `$cmd` に対して `cmd_$cmd` と `$cmd` の二種類の
メソッド呼び出しの規約を用意しています。こうすることにより、
標準入出力や終了コードを操作したいケースも対応できます。

```perl
unless (caller) {
  my $obj = __PACKAGE__->new(__PACKAGE__->parse_options(\@ARGV));

  my $cmd = shift || 'help';

  if (my $sub = $obj->can("cmd_$cmd")) {
    # cmd_FOO があるので、後は任せる
    $sub->($obj, @ARGV);

  } elsif ($sub = $obj->can($cmd)) {
    # 一般の任意のメソッドを試すケース
    my @res = $sub->($obj, @ARGV);

    # 呼び出し側で、デフォルトのシリアライザを通して出力
    print Data::Dumper->new([@res])->Terse(1)->Indent(0)->Dump, "\n";

  } else {
    $obj->cmd_help("No such command: $cmd");

  }
}
```

この方法のメリットは

- （`$self` とそこから初期化される変数に限れば）オブジェクトを扱える
- 前節同様、メソッドの引数に HASH/ARRAY を渡したい場合は JSON を使う方法が使える
  - parse_options でも JSON の decode を行えば、HASH/ARRAY を new に渡せる
- 出力も JSON に揃えると、組み合わせやすさが更に向上する
- Modulino 化のためのモジュールを作っておくことも可能。
CLI から Object の API へのマッピングが統一できるので、使えば使うほど馴染む。


### この方法の短所

- 既存のモジュールの、引数に Object を期待するメソッドは、正しく呼び出せない

つまり、最初から SCALAR か生の HASH/ARRAY しか受け取らないように
設計されたメソッドしか、コマンド行からは試せない事を意味します。

しかし逆にこの短所は、特に何でも Web API との親和性が求められがちな
現代のソフトウェア環境では、下手に class の付いた Object を
引数・戻り値として受け渡しするより、生 HASH/ARRAY をやり取りしたほうが
安全確実であるという考え方もありそうです。
ですので、これはひどい弱点にはならないかもしれない…私はそう考えています。

また、生HASH を扱う際の構造の保証には、fields 宣言による静的検査を使うことも
出来るでしょう。
- - - -
