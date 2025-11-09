---
marp: true
title: コマンド行から簡単に new してメソッドを試したい、タブ補完もしたい… MouseX::OO_Modulino と 関連モジュールのご紹介
---

# コマンド行から簡単に new して
# メソッドを試したい、タブ補完もしたい…
# MouseX::OO_Modulino と
# 関連モジュールのご紹介

by hkoba / @hkoba

---

### 私が皆さんに布教したい、アイディア

# **オブジェクト指向の** モジュリーノ

* モジュリーノとは：**ライブラリ** を **実行プログラム** と兼用する技法

* ↑ここ↑に **オブジェクト指向を組み合わせる**

* **探索的なプログラム開発** が、はかどる〜

---

### **ライブラリ** を **実行プログラム** と兼用する技法

- Python
  ```python
  if __name__ == '__main__':
      main()
  ```
- Ruby
  ```ruby
  if __FILE__ == $0
    main()
  end
  ```
- Deno
  ```typescript
  if (import.meta.main) {
    main()
  }
  ```

---

### Perl

```perl
unless (caller) {
  main()
}
```

- Brian d foy 氏が Modulino（モジュリーノ）と命名(2004)

---

## この `main()` で

- オブジェクトの new
- メソッドの dispatch
- 結果のシリアライズ

をすると、**探索的なプログラム開発** が、はかどりますよ！

---

### 例えば、
### こんな使い方をするオブジェクトを書いた時…

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
  ./MyClass.pm \
     \
     --foo=abc --bar='[3,4,5]' \
     \
     funcA '{"a":3,"b":8}'
```

- オプション＝オブジェクトのパラメータ
- サブコマンド＝メソッド名

---

### もっと言うと

- `--<TAB>` で、オプション名を補完したい
  ```sh
    ./MyClass.pm --<TAB>
  ```

- `<TAB>` で、メソッド名を補完したい
  ```sh
    ./MyClass.pm <TAB>
  ```

---

# 作ってみました
## MouseX::OO_Modulino

<https://github.com/hkoba/perl-MouseX-OO_Modulino>

### Zsh のタブ補完：App::oo_modulino_zsh_completion_helper

<https://metacpan.org/pod/App::oo_modulino_zsh_completion_helper>

---

# 使い方

- 
  ```perl
  use Mouse;
  # ↓
  use MouseX::OO_Modulino -as_base;
  ```
- 先頭
  ```perl
  #!/usr/bin/env perl
  ```
- 末尾
  ```perl
  __PACKAGE__->cli_run(\@ARGV) unless caller;
  1;
  ```
- `chmod +x ./MyClass.pm`
---
# デモ

---

# ありそうな質問

---

# 誤解されがちなポイント

- <s>便利な CLI コマンドを作る</s>

* 任意のメソッドを、コマンド行からすぐ試せるように

  - 試しやすいメソッドを書く
