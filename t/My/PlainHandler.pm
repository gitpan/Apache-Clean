package My::PlainHandler;

use Apache::RequestIO ();  # for puts()
use Apache::RequestRec (); # for $r->content_type

use Apache::Const -compile => qw(OK);

sub handler {
  my $r = shift;

  $r->content_type('text/plain');
  $r->puts('This is a plain test');

  return Apache::OK;
}

1;
