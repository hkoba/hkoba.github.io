package Class::Accessor::Fields; # XXX: Fake module
use strict; use warnings;
sub import {
  my ($pack, @fields) = @_;
  my ($callpack) = caller;
  {
    my $const = $callpack;
    *{globref($callpack, 'MY')} = sub () {$const};
  }
  my $fields = fields_hash($callpack);
  foreach my $f (@fields) {
    $fields->{$f} = 1;
    next if $f =~ /^_/;
    my $name = $f;
    *{globref($callpack, $name)} = sub {shift->{$name}};
    *{globref($callpack, "set_".$name)} = sub {shift->{$name} = shift};
  }
}

sub globref {
  my $pack_or_obj = shift;
  my $pack = ref $pack_or_obj || $pack_or_obj;
  my $symname = join("::", $pack, @_);
  no strict 'refs';
  \*{$symname};
}

sub fields_hash {
  my $sym = globref($_[0], 'FIELDS');
  # XXX: return \%{*$sym}; # If we use this, we get "used only once" warning.
  unless (*{$sym}{HASH}) {
    *$sym = {};
  }
  *{$sym}{HASH};
}
1;
