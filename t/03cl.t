use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_lwp;

# test Content-Length logic

my $response = GET '/option/index.txt';
ok ($response->header('content-length') == 59);

$response = GET '/option/index.html';
ok (! $response->header('content-length'));
