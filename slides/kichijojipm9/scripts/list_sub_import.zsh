#!/bin/zsh

set -e

perl=$(plenv which perl)

cd $perl:h:h/lib

find -name \*.pm | xargs perl -nle '
if (/^sub import \{.*?\}$/) { print "==$ARGV\n\t$_" }
elsif (my $ln = m/^sub import \{/ .. /^\}/) {
  print "==$ARGV" if $ln == 1;
  print;
  print "" if $ln =~ /E0/;
};
close ARGV if eof'
