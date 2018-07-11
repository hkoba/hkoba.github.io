#!/usr/bin/env perl
use strict;
use warnings;


my $obj = MyScript->new(
  to => ['someone@example.com', 'otherguy@example.com'],
  dbi => ["dbi:SQLite:dbname=foo.db", '', '', {sqlite_unicode => 1}],
);

$obj->list_changed_project(
  {project_dir => "/var/www/inst1"},
  {project_dir => "/var/www/inst2"},
);
