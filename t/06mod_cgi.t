use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# make sure that plain mod_cgi content comes through unaltered

my $response = GET '/cgi-bin/plain.cgi';
chomp(my $content = $response->content);

ok ($content eq q!<strong>this should be unaltered<strong>!);
ok ($response->header('content_type') =~ m!text/plain!);

# mod_cgi + SSI + Apache::Clean

$response = GET '/cgi-bin/include.cgi';
chomp($content = $response->content);

ok ($content eq q!<b>/cgi-bin/include.cgi</b>!);
ok ($response->header('content_type') =~ m!text/html!);
