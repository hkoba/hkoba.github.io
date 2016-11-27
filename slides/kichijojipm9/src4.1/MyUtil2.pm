use strict;
use warnings;
package MyUtil2 {
  require strict;
  require warnings;
  require parent;
  require Exporter;

  sub import {
    my ($class, @args) = @_;

    strict  ->import();
    warnings->import();
    parent  ->import();
    goto &Exporter::import;
  }

  our @EXPORT_OK = qw/baz/;
  sub baz { "BAZ" }
} 1;
