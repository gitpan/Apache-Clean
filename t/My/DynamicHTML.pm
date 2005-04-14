package My::DynamicHTML;

use Apache2::RequestIO ();  # for $r->print
use Apache2::RequestRec (); # for $r->content_type

use Apache2::Const -compile => qw(OK);

use strict;

sub handler {

  my $r = shift;

  $r->content_type('text/html');
  $r->print(q!<i    ><strong>&quot;This is a test&quot;</strong></i   >!);

  return Apache2::Const::OK;
}

1;
