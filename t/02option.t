use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_lwp;

# test CleanOption

chomp(my $content = GET_BODY '/option/index.html');
ok ($content eq q!<b>"This is a test"</b><i> </i>!);
