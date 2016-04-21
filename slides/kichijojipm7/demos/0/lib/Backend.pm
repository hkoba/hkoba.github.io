package Backend;
use strict;
use warnings;

use Class::Accessor::Fields qw/_DBH
			       dbi
			       db_user
			       db_pass
			      /;
use DBI;

sub DBH {
  (my MY $self) = @_;

  $self->{_DBH} //= do {
    DBI->connect($self->{dbi}
		 , $self->{db_user}, $self->{db_pass}
		 , {PrintError => 0, RaiseError => 1, AutoCommit => 1});
  };
}

1;
