#!/usr/bin/perl -l
use MyUtil
  (qw/croak/                  # 関数名
   , [lib    => qw/lib/]      # ディレクトリ・パス名
   , [parent => qw/Foo/]      # クラス名
   , [fields => qw/bar baz/]  # $self の key
 );

use Data::Dump qw/pp/;

print 'croak(): ';          pp(__PACKAGE__->can("croak"));
print "INC: ";              pp(\ @INC);
print "__PACKAGE__->foo: ", __PACKAGE__->foo;
print "\n";
print '@ISA: ';             pp(\ our @ISA);
print '%FIELDS: ';          pp(\ our %FIELDS);


