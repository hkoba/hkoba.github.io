# 提案：git 管理された /usr/local/perl5

標準的な Linux ディストリビューションの `/usr/bin/perl` で
cpanm や cpm を使ってグローバルにインストールした CPAN モジュール群は、
Perl [Config](https://perldoc.perl.org/Config) の [`installsitearch`](https://perldoc.perl.org/Config#installsitearch) [`installsitelib`](https://perldoc.perl.org/Config#installsitelib) の指すディレクトリにインストールされる。<small>(※)</small>

```sh
% perl -MConfig -le 'print "$_=$Config{q(installsite).$_}" 
  for qw(arch lib)'

# CentOS Stream 8 の場合（Perl 5.26）
arch=/usr/local/lib64/perl5
lib=/usr/local/share/perl5

# Fedora 36 の場合
arch=/usr/local/lib64/perl5/5.34
lib=/usr/local/share/perl5/5.34
```

そこで、これらのディレクトリを symlink にし、
実体は `/usr/local/perl5` に置いて、そこを git の管理下に置くのはどうだろうか…？

```sh
% cd /usr/local

% ls -ld lib64/perl5 share/perl5
lrwxrwxrwx. 1 root root  20  8月 23 14:09 lib64/perl5 -> ../perl5/lib64/perl5
lrwxrwxrwx. 1 root root  20  8月 23 14:09 share/perl5 -> ../perl5/share/perl5

% tree -L 2 perl5
perl5
├── cpanfile
├── lib64
│   └── perl5
├── make-symlink.zsh
├── run-cpm.zsh
└── share
    └── perl5
```


---

<small>※ sitearchexp, sitelibexp を参照した方が良いかもしれません</small>
