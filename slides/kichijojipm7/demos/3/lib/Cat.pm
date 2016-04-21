package Cat;
use MOP4Import::Base::Configure
  -as_base
  , [fields => qw/name birth_year/]; # field declaration

sub after_new {
  (my MY $self) = @_;
  $self->{birth_year} //= $self->_this_year;
}

sub age {
  my Cat $self = shift;
  return $self->_this_year
    - $self->{birth_year};	# Checked!
}

sub _this_year { (localtime)[5] + 1900 }

1;
