use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

use File::Spec;

my $index    = File::Spec->catfile('htdocs', 'index.html');
my $conf     = File::Spec->catfile('conf', 'httpd.conf');
my $package  = File::Spec->catfile('..', 'blib', 'lib', 'Apache', 'Clean.pm');

plan tests => 21, \&have_lwp;

my $response = GET '/option/index.html';
ok $response->code == 200;

sleep 1; # wait just a bit

# this should be the same document - no changes
my $response1 =  GET '/option/index.html';
ok $response1->code == 200;
ok ($response1->header('last_modified') eq $response->header('last_modified'));
ok ($response1->header('etag') eq $response->header('etag'));

my $rc = system('touch', $index) >> 8;
ok(!$rc);
sleep 1;

# we changed the mtime on the doc, so attributes should differ
my $response2 =  GET '/option/index.html';
ok $response2->code == 200;
ok ($response2->header('last_modified') ne $response1->header('last_modified'));
ok ($response2->header('etag') ne $response1->header('etag'));

sleep 1;

# same as the last time
my $response3 =  GET '/option/index.html';
ok $response3->code == 200; 
ok ($response3->header('last_modified') eq $response2->header('last_modified'));
ok ($response3->header('etag') eq $response2->header('etag'));

=pod   # don't do this yet
$rc = system('touch', $conf) >> 8;
ok(!$rc);
sleep 1;

# we changed the mtime on the conf, so Last-Modified should differ
# but the Etag should be the same
my $response4 =  GET '/option/index.html';
ok $response4->code == 200;
ok ($response4->header('last_modified') ne $response3->header('last_modified'));
ok ($response4->header('etag') eq $response3->header('etag'));

sleep 1;

# same as last time
my $response5 =  GET '/option/index.html';
ok $response5->code == 200;
ok ($response5->header('last_modified') eq $response4->header('last_modified'));
ok ($response5->header('etag') eq $response4->header('etag'));
=cut

# this is a different location, but the file is the same
my $response6 =  GET '/reload/index.html';
ok $response6->code == 200;
#ok ($response6->header('last_modified') eq $response5->header('last_modified'));
#ok ($response6->header('etag') eq $response5->header('etag'));
ok ($response6->header('last_modified') eq $response3->header('last_modified'));
ok ($response6->header('etag') eq $response3->header('etag'));

$rc = system('touch', $package) >> 8;
ok(!$rc);
sleep 1;

# we changed the mtime on the package, so Last-Modified should differ
# but the Etag should be the same
my $response7 =  GET '/reload/index.html';
ok $response7->code == 200;
ok ($response7->header('last_modified') ne $response6->header('last_modified'));
ok ($response7->header('etag') eq $response6->header('etag'));

sleep 1;

# same as last time
my $response8 =  GET '/reload/index.html';
ok $response8->code == 200;
ok ($response8->header('last_modified') eq $response7->header('last_modified'));
ok ($response8->header('etag') eq $response7->header('etag'));

