use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_lwp;

# test Content-Length logic

# plain text is handled my default-handler which sets C-L
my $response = GET '/option/index.txt';
ok ($response->header('content-length') == 59);

# html is handled by the filter which removes C-L
$response = GET '/option/index.html';
ok (! $response->header('content-length'));
