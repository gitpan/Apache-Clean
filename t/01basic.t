use strict;
use warnings FATAL => 'all';

use Apache::Test;

plan tests => 3;

ok require 5.005;
ok require mod_perl;
ok $mod_perl::VERSION >= 1.21;

# can't do this test anymore as long
# as we're calling Apache->server_root_relative
# ok require Apache::Clean;
