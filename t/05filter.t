use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, \&have_filter;

my $content = GET_BODY '/filter/index.html';
chomp $content;
ok ($content eq q!<b>"This is a test"</b><i> </i>!);

sub have_filter {
  eval { 
    die unless have_lwp();
    require Apache::Filter;
  };
  return $@ ? 0 : 1;
}
