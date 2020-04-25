### (OOな) Modulino のメソッド名を
### Zsh で補完してみる

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)
→ [`hachiojipm` `#79`](http://hkoba.github.io/slides/hachiojipm79/)

---

## (OO な) Modulino

```console
% ./Greetings.pm hello
Hello world
```

.pm だけど、コマンドとしても実行できる。


```console
% perl -I. -MGreetings -le 'print Greetings->new(name => "world")->hello'
```

勿論モジュールとして使える

---

```perl
#!/usr/bin/env perl
package Greetings;
use strict;
use warnings;

unless (caller) {
  my $cmd = shift
    or die "Usage: $0 COMMAND ARGS...\n";

  print __PACKAGE__->new(name => "world")->$cmd(@ARGV), "\n";
}

sub new  { my $class = shift; bless +{@_}, $class }

sub hello { my $self = shift; join " ", "Hello", $self->{name} }
1;
```

---

### サブコマンド名を補完して欲しい

```console
% ./Greetings.pm <TAB>
```

---

### オプション名も(あるなら)
### 補完して欲しい


```console
% ./Greetings.pm --<TAB>
```

---

## デモ

---

## リポジトリこれ


https://github.com/hkoba/perl-App-oo_modulino_zsh_completion_helper


