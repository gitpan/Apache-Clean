use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

my $response = GET '/plain-dynamic';
my $content = $response->content;
chomp $content;
ok ($content eq q!This is a plain test!);
ok ($response->header('content_type') eq 'text/plain');

$response = GET '/plain-static/index.txt';
$content = $response->content;
chomp $content;
ok ($content eq q!This is a plain test!);
ok ($response->header('content_type') eq 'text/plain');

