package My::DynamicHTML;

use Apache::RequestIO ();  # for puts()
use Apache::RequestRec (); # for $r->content_type

use Apache::Const -compile => qw(OK);

sub handler {
  my $r = shift;

  $r->content_type('text/html');
  $r->puts(<<EOF);
<html>
<head>
  <title></title>
</head>
<body>
some inline HTML
</body>
</html>
EOF

  return Apache::OK;
}

1;
