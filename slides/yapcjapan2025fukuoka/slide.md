---
marp: true
---

# JSON 指向の OO Modulino と 
# Agentic Coding の相性<small>について</small>

hkoba

---

who am I

---

## 今日お話する内容

1. JSON 指向の OO Modulino（モジュリーノ） とは

   * 例は Perl 中心ですが、Perl に限らない概念

2. それが Agentic Coding と、どう相性が良いか

---

## JSON 指向の Object-Oriented Modulino（モジュリーノ） とは

1. Modulino（＝モジュールかつ CLI コマンド） である

2. CLI からオブジェクトを new して、任意のメソッドを呼び試せる

3. CLI から JSON 形式で引数を渡せる
   - 戻り値も（極力）JSON で統一する


---

# 1. Modulino（＝モジュールかつ CLI コマンド）

- モジュール（部品）として、他のコードから利用できる、プログラムファイル
- 単体のコマンドとしても実行できる

---

# Modulino の例：Perl

```console
# モジュールとして利用できる
% perl -I$PWD -le 'use Foo; print Foo::bar()'

# 単体コマンドとしても実行できる
% ./Foo.pm
```

---

## Foo.pm の中身の例

<!--**file samples/01/Foo.pm **-->
```perl
#!/usr/bin/perl
#**use v5.40; use feature 'class'; no warnings qw(experimental::class);

class Foo;

sub bar {"baz"}

unless (caller) {
  print Foo->bar(@ARGV), "\n";
}
```

---

# 誤解しがちなポイント

便利な CLI コマンドを作ることは、目的ではない。

モジュールの細部を CLI から試せることが目的


---

CC, 凄くマイクロコントロールしてる


- 思い込みが強いけど、恐ろしく手が早い、新人
