use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# dynamic content generation tests

# dynamic but plain content should be unaltered

my $response = GET '/plain-dynamic';
my $content = $response->content;
chomp $content;

ok ($content eq q!<strong>&quot;This is a test&quot;</strong><i    > </i   >!);
ok ($response->header('content_type') =~ m!text/plain!);

# dynamic HTML should get filtered
$response = GET '/html-dynamic';
$content = $response->content;
chomp $content;

ok ($content eq q!<b>"This is a test"</b><i> </i>!);
ok ($response->header('content_type') =~ m!text/html!);
