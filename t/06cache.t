use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

my $response = GET '/option/index.html';
ok $response->code == 200;

my $rc = system('touch', 'htdocs/index.html') >> 8;
ok(!$rc);

my $response2 =  GET '/option/index.html';
ok $response->code == 200;
ok ($response->header('last_modified') ne $response2->header('last_modified'));
