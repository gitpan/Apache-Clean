use strict;
use warnings FATAL => 'all';

use Apache::Test;

plan tests => 4;

ok require 5.005;
ok require mod_perl;
ok $mod_perl::VERSION >= 1.21;
ok require Apache::Clean;
