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
  # ... dummy ...
};
