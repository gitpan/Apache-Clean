use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, \&have_lwp;

# this tests whether we can properly
# store broken tags in the filter context
# if data is sent over multiple filter invocations

my $response = GET '/extra';
my $content = $response->content;
chomp($content);
ok($content eq ('x' x 1020) . '</body></html');
