package MyUtil {
  use MOP4Import::Declare -as_base;
  use Carp;

  sub declare_lib {
    my ($class, $opts, $callpack, @args) = @_;
    unshift @INC, @args;
  }
} 1;
