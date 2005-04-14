package My::Uppercase;

use Apache2::Filter ();

use Apache2::Const -compile => qw(OK);

use strict;

sub handler {

  my $f   = shift;

  while ($f->read(my $buffer, 1024)) {
    $f->print(uc $buffer);
  }

  return Apache2::Const::OK;
}

1;
