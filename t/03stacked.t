use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, have_lwp;

my $response = GET '/filter/index.html';
my $content = $response->content;
chomp $content;
ok $response->code == 200;
ok ($content eq q!<b>"This is a test"</b><i> </i>!);

