use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_lwp;

my $content = GET_BODY '/option/index.html';
chomp $content;
ok ($content eq q!<b>"This is a test"</b><i> </i>!);
