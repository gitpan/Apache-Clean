use strict;
use warnings FATAL => 'all';

use Apache2 ();
use Apache::TestRunPerl ();

Apache::TestRunPerl->new->run(@ARGV);
