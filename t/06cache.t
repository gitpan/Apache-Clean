use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

my $headers1 = get_head('/option/index.html');
ok ($headers1->{status} == 200);

my $rc = system('touch', 'htdocs/index.html') >> 8;
ok(!$rc);

my $headers2 = get_head('/option/index.html');
ok ($headers2->{status} == 200);
ok ($headers1->{last_modified} ne $headers2->{last_modified});

sub get_head {

  my $uri = shift;

  my $content = GET_HEAD $uri;

  my ($status) = $content =~ m!HTTP/1.\d (\d+)!;
  my ($last_modified) = $content =~ m!Last-Modified:(.*)\n!;
  my ($etag) = $content =~ m!ETag:(.*)\n!;

  my $headers = { status => $status,
                  last_modified => $last_modified,
                  etag => $etag};

  return $headers;
}
