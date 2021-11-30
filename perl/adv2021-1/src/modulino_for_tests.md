# UnitTest の実行

モジュールを起動した時には、そのモジュールのテストを実行する、
という方法です。これは [Self testing Perl modules using the Modulino concept](https://perlmaven.com/self-testing-with-modulino) や[Modulino::Test](https://metacpan.org/pod/Modulino::Test)でも紹介されています。

例えば、初期のプロトタイピングの段階で、
テストのための環境とファイルを整える時間的・心理的余裕がない、
というケースを仮に考えましょう。その場合、モジュールファイルの中に
テストも書いてしまえるなら、その分、テストを書き始める時期を前倒しに
出来る、というメリットが有るでしょう。

以下は [Self testing Perl modules using the Modulino concept](https://perlmaven.com/self-testing-with-modulino) の例の抜粋です。
モジュールをコマンドとして実行したときには self_test() が呼ばれます。

```perl
sub add { ... }

sub self_test {
	require Test::More;
	import Test::More;
	plan(tests => 4);
	is(add(2, 5), 7);
	is(add(-1, 1), 0);
	is(add(23, 1), 0);
	is(add(0, 10), 10);
}
 
self_test() unless caller();
```

### この方法の短所

1. 開発が進みテストが巨大化したら、テストを別ファイルに移動する必要が有る

2. テストしか呼べない。他の機能を呼ぶには、コーディングが必要

が挙げられます。

- - - -
