package MyClass;
use Mouse;

has foo => (is => 'rw', isa => 'Str', default => "FOO",
            documentation => "is string");

has bar => (is => 'rw', isa => 'ArrayRef[Int]');

sub funcA {
  my ($self, $param) = @_;
  [$self->{foo}, $param]
}

sub funcB {
  my ($self, $param) = @_;
  +{bar => $self->{bar}, baz => $param}
}

1;
