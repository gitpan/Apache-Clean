#!perl

use 5.008;

use ModPerl::MM ();
use Apache::TestMM qw(test clean);
use Apache::TestRunPerl ();

# configure tests based on incoming arguments
Apache::TestMM::filter_args();

# provide the test harness
Apache::TestRunPerl->generate_script();

# now, write out the Makefile
ModPerl::MM::WriteMakefile(
  NAME         => 'Apache::Clean',
  VERSION_FROM => 'Clean.pm',
  PREREQ_PM    => { HTML::Clean => 0.8,
                    mod_perl2   => 0, },
);
