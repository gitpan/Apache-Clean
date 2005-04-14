package My::Extra;

use Apache2::RequestIO ();  # for $r->print
use Apache2::RequestRec (); # for $r->content_type

use Apache2::Const -compile => qw(OK);

use strict;

sub handler {

  my $r = shift;

  $r->content_type('text/html');

  # leave some rogue tag dangling off our HTML,
  # as if there were some improperly formatted
  # data or something
  $r->print('x' x 1020 . '</body></html');

  return Apache2::Const::OK;
}

1;
