use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_lwp;

my $response = GET '/html-dynamic';
my $content = $response->content;
ok ($content =~ m!<html><head><title></title></head><body>\n!);
ok ($response->header('content_type') eq 'text/html');

# skip this test until I figure this mtime stuff out
#ok (! $response->header('last-modified'));

