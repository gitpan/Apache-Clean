use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_lwp;

# make sure that non-HTML documents pass through unaltered

my $response = GET '/option/index.txt';
chomp(my $content = $response->content);

ok ($content eq q!<strong>&quot;This is a test&quot;</strong><i    > </i   >!);
ok ($response->header('content_type') =~ m!text/plain!);

