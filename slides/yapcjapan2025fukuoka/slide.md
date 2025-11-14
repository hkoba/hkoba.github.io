---
marp: true
title: コマンド行から簡単に new してメソッドを試したい、タブ補完もしたい… MouseX::OO_Modulino と 関連モジュールのご紹介
---

# コマンド行から簡単に new して
# メソッドを試したい、タブ補完もしたい…
## MouseX::OO_Modulino と
## 関連モジュールのご紹介

by hkoba / [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)

---

### 一番、伝えたいこと

# **モジュリーノ** x **オブジェクト指向**
# ＝ **探索的なプログラム開発** に便利！

* モジュリーノとは：<u>**ライブラリ・ファイル** が **実行プログラム** を兼ねたもの</u>
  * またはそのための技法

    -  Brian d foy 氏により命名(2004)

---

### **ライブラリ・ファイル** に **実行プログラム** を兼ねさせる技法

- 多くの言語に存在

- Perl の場合：
  ```perl
  unless (caller) {
    main()
  }
  ```
* Python
  ```python
  if __name__ == '__main__':
      main()
  ```
* Ruby
  ```ruby
  if __FILE__ == $0
    main()
  end
  ```

---

### **ライブラリ** に **実行プログラム** を兼ねさせる技法

- Deno
  ```typescript
  if (import.meta.main) {
    main()
  }
  ```
- Tcl
  ```tcl
  if {![info level] && [info script] eq $::argv0} {
    main
  }
  ```
- Zsh
  ```sh
  if (($#zsh_eval_context == 1 && $zsh_eval_context[1] == "toplevel")); then
    main
  fi
  ```

---

## この `main()` に代えて、

* オブジェクトの new
* メソッドの dispatch
* 結果のシリアライズ

をすると、**探索的なプログラム開発** が、はかどりますよ！

* 名付けて、OO Modulino（おーおー、モジュリーノ）！

---

# 例えば…
---

### こんな使い方をするクラスを書いた時…

```perl
  MyClass
  
    ->new(foo => "abc", bar => [3,4,5])
  
    ->funcA({a => 3, b => 8})
```

---

### コマンド行から試すには…

```sh
perl -I$PWD -le 'use MyClass; use Data::Dumper; print Dumper(

  MyClass
  
    ->new(foo => "abc", bar => [3,4,5])
  
    ->funcA({a => 3, b => 8})
)'
```

…大分、面倒…

---

#### もっと直接的に…

```perl
  MyClass
  
    ->new(foo => "abc", bar => [3,4,5])
  
    ->funcA({a => 3, b => 8})
```

### ↓このくらいで済ませたい！

```sh
  ./MyClass.pm                          \
                                        \
     --foo=abc --bar='[3,4,5]'          \
                                        \
     funcA '{"a":3,"b":8}'
```

- `--オプション=値` → new する時のパラメータ
- `サブコマンド` → メソッド名

---

### もっと欲を言えば…

- `<TAB>` で、メソッド名を補完したい
  ```sh
    ./MyClass.pm <TAB>
  ```
- `--<TAB>` で、オプション名を補完したい
  ```sh
    ./MyClass.pm --<TAB>
  ```

---

# 作ってみました！
## MouseX::OO_Modulino

<https://github.com/hkoba/perl-MouseX-OO_Modulino>

- Mouse （Perl の OOP フレームワークの一つ）の拡張

---

### Zsh のタブ補完も：App::oo_modulino_zsh_completion_helper

<https://metacpan.org/pod/App::oo_modulino_zsh_completion_helper>

---

# 使い方

- Mouse を置き換え
  ```perl
  use Mouse;
  # ↓
  use MouseX::OO_Modulino -as_base;
  ```
- 先頭に shebang
  ```perl
  #!/usr/bin/env perl
  ```
- 末尾に unless caller
  ```perl
  __PACKAGE__->cli_run(\@ARGV) unless caller;
  1;
  ```
- `chmod +x ./MyClass.pm`
---
# デモ

```perl
package MyClass;
use Mouse;

has foo => (is => 'rw', isa => 'Str', default => "FOO",
            documentation => "is string");

has bar => (is => 'rw', isa => 'ArrayRef[Int]');

sub funcA {
  my ($self, $param) = @_;
  [$self->{foo}, $param]
}

sub funcB {
  my ($self, $param) = @_;
  +{bar => $self->{bar}, baz => $param}
}
1;
```

---

1. 元のコードを説明
2. CLI から Data::Dumper で試すコードを実行
3. OO Modulino へ書き換え
4. コマンド行から呼び出してみる
5. タブ打ってみる

---

# まとめ

- **モジュリーノ** x **オブジェクト指向** ＝ **探索的なプログラム開発** に便利！
- 他の言語でも、あると便利かも？（既に有る？）

---

# ありそうな質問

---

# 使ってる？

* 同じ仕組みの別モジュールを仕事で使ってる
  - [CLI_JSON](https://metacpan.org/dist/MOP4Import-Declare/view/Base/CLI_JSON.pod) 2017〜
  - Zsh 補完は 2020〜

* アイディアだけでも広めたい → 今回 Mouse へ移植

---

# Zsh だけ？ Bash は？

* 拡張子に対する補完を用いている
  ```sh
  compdef -P (*/)#*.pm
  ```
* bash だと難しそう…

---

# 誤解されがちなポイント

- <s>便利な CLI コマンドを作る</s>

* 任意のメソッドを、コマンド行からすぐ試せるように

  - メソッドを小さく、試しやすく書く動機につながる
