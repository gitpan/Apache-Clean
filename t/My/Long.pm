package My::Long;

use Apache2::RequestIO ();  # for $r->print
use Apache2::RequestRec (); # for $r->content_type

use Apache2::Const -compile => qw(OK);

use strict;

sub handler {

  my $r = shift;

  $r->content_type('text/html');
  my $buffer = 'x' x $r->args;
  $r->print(qq!$buffer<strong></strong>!);

  return Apache2::Const::OK;
}

1;
