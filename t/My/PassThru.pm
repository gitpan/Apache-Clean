package My::PassThru;

use Apache::Filter ();

use Apache::Const -compile => qw(OK);

use strict;

sub handler {

  my $f   = shift;

  # just pass data through
  while ($f->read(my $buffer, 1024)) {
    $f->print($buffer);
  }

  return Apache::OK;
}

1;
