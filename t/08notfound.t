use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# make sure that non-OK codes are handled properly
# 404 is a good enough example to try

my $response = GET '/level/foo.html';
ok ($response->code == 404);

$response = GET '/level/foo.txt';
ok ($response->code == 404);

$response = GET '/cgi-bin/foo.cgi';
ok ($response->code == 404);

$response = GET '/perl-bin/foo.cgi';
ok ($response->code == 404);

