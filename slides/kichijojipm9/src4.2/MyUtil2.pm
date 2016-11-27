use strict;
use warnings;
package MyUtil2 {
  use Sub::Uplevel;
  require strict;
  require warnings;
  require parent;
  require Exporter;

  sub import {
    my ($class, @args) = @_;

    strict  ->import();
    warnings->import();
    uplevel 1, \&parent::import;
    uplevel 1, \&Exporter::import, @args;
  }

  our @EXPORT_OK = qw/baz/;
  sub baz { "BAZ" }
} 1;

# % perl -Isrc4.2 -e 'use MyUtil2 qw/baz/; print @main::ISA,"\n"; print baz()'
#
# Undefined subroutine &main::baz called at -e line 1.
