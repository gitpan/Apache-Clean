use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# test filtering content from mod_cgi

# make sure that plain content comes through unaltered
my $response = GET '/cgi-bin/plain.cgi';
my $content = $response->content;
chomp $content;

ok ($content eq q!<strong>this should be unaltered<strong>!);
ok ($response->header('content_type') =~ m!text/plain!);

# mod_cgi + SSI + Apache::Clean
$response = GET '/cgi-bin/include.cgi';
$content = $response->content;
chomp $content;

ok ($content eq q!<b>/cgi-bin/include.cgi</b>!);
ok ($response->header('content_type') =~ m!text/html!);
