# 任意の関数のDispatch

モジュールを CLI から起動した時に、渡された第一引数をサブコマンド
として解釈する考えです。

```perl
package Foo;

sub hello { print "hello!\n" }
sub goodbye {print "goodbye!\n" }

unless (caller) {

  my $funcName = shift
    or die "function name is required!";

  my $func = __PACKAGE__->can($funcName)
    or die "No such function: $funcName";
  
  print Dumper($func->(@ARGV));
};1
```

この方式なら、任意の関数をコマンド行から呼び出すことが可能になります。

```console
% ./Foo.pm hello
hello!
% ./Foo.pm goodbye
goodbye!
```

- 関数に引数として HASH/ARRAY を渡したいケースもありえます。その場合は
コマンド行引数に `{...}` や `[...]` が渡されたときだけ、 **JSON として decode**
する、というアプローチを取ることが可能でしょう。

  - その場合、 **出力も JSON として encode** しておけば、コマンド行を glue として関数同士を組み合わせることも可能になるでしょう。

- この unless caller ブロック内のロジックを予め別のモジュールとして
準備しておけば、個々のモジュールにおける Modulino 化のコーディング負担は
極めて少なくなります。

### この方法の短所

この方法では、

- CLI から OOP のオブジェクトを一切扱えない（オブジェクトを扱う関数は、呼び出してもエラーになる）
- サブコマンドを覚えるのが面倒、という考え方も有るかもしれません。  
ただ、これは shell の側で補完機能を用意出来れば、問題ではなくなるでしょう。

という弱点があります。これは現代の Perl プログラムにとっては
かなり痛い制限です。
