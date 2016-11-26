package Bar {
  sub import {
    my ($class, @args) = @_;

    my $callpack = caller;

    no strict 'refs';
    *{$callpack."::bar"} = sub { "BAR" };
  }
} 1;
