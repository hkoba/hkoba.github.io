#!/usr/bin/env perl
package OpenGraphMeta;
use strict;
use warnings;

use MOP4Import::Base::CLI_JSON -as_base;

MY->run(\@ARGV) unless caller;

1;
