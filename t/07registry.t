use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# Apache::Registry 

# make sure that plain content comes through unaltered
my $response = GET '/perl-bin/plain.pl';
my $content = $response->content;
chomp $content;

ok ($content eq q!<strong>this should be unaltered<strong>!);
ok ($response->header('content_type') =~ m!text/plain!);

# Apache::Registry + SSI + Apache::Clean
$response = GET '/perl-bin/include.pl';
$content = $response->content;
chomp $content;

ok ($content eq q!<b>/perl-bin/include.pl</b>!);
ok ($response->header('content_type') =~ m!text/html!);
