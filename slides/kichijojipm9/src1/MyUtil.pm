use strict;
package MyUtil {

  use Exporter qw/import/;

  our @EXPORT_OK = qw/foo $bar @baz/;

  sub foo {"FOO"}
  our $bar = "BAR";
  our @baz = ('BAZ');

} 1;
