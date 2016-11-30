use strict;
use warnings;
package MyUtilX {
  require parent;
  require Bar;

  sub import {
    my ($class, @args) = @_;
    parent ->import();
    Bar    ->import(@args);
  }

} 1;
