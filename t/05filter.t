use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 3, \&have_filter;

my $response = GET '/filter/index.html';
my $content = $response->content;
chomp $content;
ok $response->code == 200;
ok ($content eq q!<b>"This is a test"</b><i> </i>!);
ok (!$response->header('last_modified'));

sub have_filter {
  eval { 
    die unless have_lwp();
    require Apache::Filter;
  };
  return $@ ? 0 : 1;
}
