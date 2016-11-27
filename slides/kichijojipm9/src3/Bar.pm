use strict;
package Bar {
  sub import {
    my ($class, @args) = @_;

    my $callpack = caller;
    print "$class is used from $callpack\n";

    my $newname = $callpack."::bar";
    print "Installing $newname...\n";

    no strict 'refs';
    *{$newname} = sub { "BAR" };
  }
} 1;
