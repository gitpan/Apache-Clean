use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_lwp;

# this tests whether returning DECLINED
# allows other filters to still see the data

my $response = GET '/decline';
my $content = $response->content;
chomp $content;

ok ($content eq q!<strong>&quot;This is a test&quot;</strong><i    > </i   >!);
ok ($response->header('content_type') =~ m!text/plain!);
