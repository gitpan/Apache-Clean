use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_lwp;

# test CleanLevel

chomp(my $content = GET_BODY '/level/index.html');
ok ($content eq q!<b>&quot;This is a test&quot;</b><i> </i>!);
