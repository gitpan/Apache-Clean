use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 4, \&have_lwp;

# make sure that plain ModPerl::Registry content comes through unaltered

my $response = GET '/perl-bin/plain.pl';
chomp(my $content = $response->content);

ok ($content eq q!<strong>this should be unaltered<strong>!);
ok ($response->header('content_type') =~ m!text/plain!);

# ModPerl::Registry + SSI + Apache::Clean

$response = GET '/perl-bin/include.pl';
chomp($content = $response->content);

ok ($content eq q!<b>/perl-bin/include.pl</b>!);
ok ($response->header('content_type') =~ m!text/html!);
