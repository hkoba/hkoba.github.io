package Bar {
  sub import {
    my ($class, @args) = @_;

    my $callpack = caller;
    print "$class is used from $callpack\n";

    no strict 'refs';
    *{$callpack."::bar"} = sub { "BAR" };
  }
} 1;
