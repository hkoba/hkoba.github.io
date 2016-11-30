use strict;
package AddInnerClass {
  sub import {
    my ($class, $innerName, $parent) = @_;

    my $callpack = caller;

    require ($parent =~ s!::!/!gr).".pm";

    my $isa = do {
      my $isa_sym = globref($callpack, $innerName, 'ISA');
      *{$isa_sym}{ARRAY} // do {
        *$isa_sym = my $array = [];
        $array;
      };
    };
    push @$isa, $parent;
  }

  sub globref {
    my $name = join "::", @_;
    no strict 'refs';
    \*{$name};
  }
} 1;
