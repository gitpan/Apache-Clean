eval "require Apache::Filter";

sub My::PlainHandler {
  my $r = shift->filter_register;

  $r->send_http_header('text/plain');
  print "This is a plain test";

  return Apache::Constants::OK;
}

sub My::DoNothingHandler {
  my $r = shift->filter_register;

  my ($fh, $status) = $r->filter_input;

  return $status unless $status == OK;

  $r->send_http_header($r->content_type);
  print while <$fh>;

  return OK;
}
1;
