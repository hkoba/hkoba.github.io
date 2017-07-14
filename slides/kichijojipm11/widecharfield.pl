use utf8;
use strict;
use fields qw/お名前 職業 年齢/;

sub MY () {__PACKAGE__}

my MY $hash = +{};

print $hash->{お名前え};
