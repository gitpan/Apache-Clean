use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_lwp;

my $content = GET_BODY '/level/index.html';
chomp $content;
ok ($content eq q!<strong>&quot;This is a test&quot;</strong><i> </i>!);
