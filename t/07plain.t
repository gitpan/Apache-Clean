use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 2, \&have_filter;

my $content = GET_BODY '/plain-dynamic';
chomp $content;
ok ($content eq q!This is a plain test!);

$content = GET_BODY '/plain-static/index.txt';
chomp $content;
ok ($content eq q!This is a plain test!);

sub have_filter {
  eval { 
    die unless have_lwp();
    require Apache::Filter;
  };
  return $@ ? 0 : 1;
}
