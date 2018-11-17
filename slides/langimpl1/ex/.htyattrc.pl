use strict;
use YATT::Lite qw/Entity/;

Entity max => sub {
  my ($this, $x, $y) = @_;
  $x < $y ? $y : $x;
};

Entity min => sub {
  my ($this, $x, $y) = @_;
  $x < $y ? $x : $y;
};

Entity query => sub {
  ... # dummy
};

#========================================

Entity current_user => sub {
  ... # dummy
};

use constant DEBUG_IFOK => $ENV{DEBUG_IFOK};
use YATT::Lite qw/lexpand terse_dump/;
use YATT::Lite::Macro;
Macro ifok => sub {
  my ($cgen, $node) = @_;
  $cgen->node_sync_curline($node);
  my ($path, $body, $primary, $head, $foot) = $cgen->node_extract($node);

  print STDERR "#ifok: primary", terse_dump($primary), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: body", terse_dump($body), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: foot", terse_dump($foot), "\n" if DEBUG_IFOK;

  # INPUT:
  # <yatt:ifok result="expr">
  #   OK
  # <:yatt:else err />
  #   ERR
  # </yatt:ifok>

  # OUTPUT:
  # my ($result, $err) = &expr;
  # if (not $err) {
  #   OK;
  # } else {
  #   ERR;
  # }

  my ($oknode, $errnode) = map {$_->[0]} $primary, $foot;

  my %spec = (ok => [$oknode, $body]
	      , err => [$cgen->node_attlist($errnode)->[0], $errnode]);

  print STDERR "#ifok: spec.ok.att", terse_dump($spec{ok}[0]), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: spec.ok.body", terse_dump($spec{ok}[1]), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: spec.err.att", terse_dump($spec{err}[0]), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: spec.err.body", terse_dump($spec{err}[1]), "\n" if DEBUG_IFOK;

  my $fmt = q|{my ($%1$s, $%2$s) = %3$s; if (not $%2$s) %4$s else %5$s}|;

  my @var_ok_ng = map {
    my ($att, $body) = @{$spec{$_}};
    $cgen->node_path($att) || $_;
  } qw/ok err/;

  print STDERR "#ifok: okvar: ", terse_dump($cgen->node_path($oknode)), "\n" if DEBUG_IFOK;
  print STDERR "#ifok: errvar: ", terse_dump($cgen->node_path($cgen->node_attlist($errnode)->[0])), "\n" if DEBUG_IFOK;

  my %scope; $scope{$_} = $cgen->mkvar_at(undef, value => $_) for @var_ok_ng;

  print STDERR "#ifok: scope: ", terse_dump(\%scope), "\n" if DEBUG_IFOK;

  my $if_expr = $cgen->as_list($cgen->node_body($spec{ok}[0]));
  print STDERR "#ifok: if_expr: ", terse_dump($if_expr), "\n" if DEBUG_IFOK;

  my $then_stat = $cgen->macro_scoped_block_of_tokens(\%scope, $cgen->node_value($spec{ok}[1]));
  print STDERR "#ifok: then_expr: ", $$then_stat, "\n" if DEBUG_IFOK;
  my $else_stat = $cgen->macro_scoped_block_of_tokens(\%scope, $cgen->node_value($spec{err}[1]));
  print STDERR "#ifok: else_expr: ", $$else_stat, "\n" if DEBUG_IFOK;

  \ sprintf($fmt, @var_ok_ng
	    , $if_expr, $$then_stat, $$else_stat);
};

